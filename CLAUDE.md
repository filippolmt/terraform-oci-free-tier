# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Terraform module for deploying Oracle Cloud Infrastructure (OCI) Free Tier resources. Provisions an ARM-based VM (VM.Standard.A1.Flex) with Docker, optional RunTipi homeserver, optional Coolify self-hosted PaaS, and optional WireGuard VPN client.

**Current version: 4.2.0** - See [CHANGELOG.md](CHANGELOG.md) for version history and breaking changes.

## Commands

```bash
# All testing runs through Docker via Makefile
make test           # Run all checks: fmt-check → validate → lint → shellcheck → security
make fmt            # Auto-format .tf files
make docs           # Regenerate README.md terraform-docs section
make shell          # Interactive shell in test container
make clean          # Remove Docker image and .terraform/

# Native equivalents (requires local tofu, tflint, trivy)
make native-test

# Direct OpenTofu commands (require terraform.tfvars)
tofu init && tofu plan
```

## Architecture

Infrastructure is split into domain-specific files (no submodules): `network.tf` (VCN, Subnet, Internet Gateway, Route Table, Security List), `compute.tf` (Instance, Public IP, data sources), and `storage.tf` (Block Volume, Volume Attachment, Backup Policy). The module creates a compute instance (ARM64, 4 OCPUs, 24GB RAM), a separate block volume (150GB) for Docker data mounted at `/mnt/data`, a reserved public IP, and a daily backup policy (3-day retention to stay within Free Tier's 5-backup limit).

### Critical Design Details

- **`prevent_destroy` on docker_volume**: The block volume in `storage.tf` has `lifecycle { prevent_destroy = true }`. Destroying the stack requires manually removing this lifecycle rule or using `tofu state rm` first.
- **No `ignore_changes` on user_data**: Changes to the startup script (`user_data`) will trigger instance recreation on `tofu apply`. The boot volume is destroyed and recreated; the block volume (data) is preserved. The `lifecycle` block contains `precondition` blocks for cross-variable validations (RunTipi/Coolify mutual exclusion, Coolify credential pairing) — these produce hard errors that block `apply`.
- **Startup script is a `templatefile()`**: `scripts/startup.sh` is rendered via `templatefile()` in the instance's `user_data` metadata block in `compute.tf`. Any new shell variable in the script must have a matching Terraform variable passed in the `templatefile()` call. Existing template variables: `ADDITIONAL_SSH_PUB_KEY`, `INSTALL_RUNTIPI`, `RUNTIPI_REVERSE_PROXY_IP`, `RUNTIPI_MAIN_NETWORK_SUBNET`, `RUNTIPI_ADGUARD_IP`, `INSTALL_COOLIFY`, `COOLIFY_ADMIN_EMAIL`, `COOLIFY_HAS_ADMIN_CREDS` (boolean flag — avoids embedding credential values in bash `[ -n ]` tests where `$`-containing passwords would crash under `set -u`), `COOLIFY_ADMIN_PASSWORD`, `COOLIFY_AUTO_UPDATE`, `WIREGUARD_CLIENT_CONFIGURATION`. The Coolify installer requires all three of `ROOT_USERNAME`, `ROOT_USER_EMAIL`, `ROOT_USER_PASSWORD` to pre-configure admin credentials — the script sets `ROOT_USERNAME` to the email value.
- **Free Tier validation rules**: `variables.tf` includes validation blocks that enforce Free Tier limits (max 4 OCPUs, max 24GB RAM, minimum volume sizes, CIDR format, fault domain format). Cross-variable validations use `precondition` blocks on `oci_core_instance` in `compute.tf` (Terraform `variable` validation blocks cannot reference other variables).
- **Region image OCIDs**: `variables.tf` contains a `instance_image_ocids_by_region` map with Ubuntu 24.04 ARM64 image OCIDs for 35+ OCI regions. When updating the base image, every region OCID must be updated. These are managed by Renovate when possible.
- **Ingress firewall rules**: Managed via `locals` in `network.tf`. SSH (22/TCP, source configurable via `ssh_source_cidr`) and ICMP fragmentation (type 3, code 4) are always enabled. HTTP (80), HTTPS (443), and WireGuard (51820/UDP) are auto-added when `install_runtipi = true`. HTTP (80), HTTPS (443) are auto-added when `install_coolify = true`; Coolify admin ports (8000/TCP UI, 6001-6002/TCP soketi real-time) use `coolify_admin_source_cidr` (default: `0.0.0.0/0`) so admin access can be restricted independently of app traffic. Ping is controlled by `enable_ping` (default: false). Custom rules use `custom_ingress_security_rules` with a simplified type (protocol + ports + source, all validated). OCI protocol identifiers: `"6"` = TCP, `"17"` = UDP, `"1"` = ICMP.
- **Egress firewall rules**: Controlled by `enable_unrestricted_egress` (default: `true` — all outbound traffic allowed). When `false`, only `egress_security_rules` are applied (default: HTTPS, HTTP, DNS, NTP).
- **Block volume performance**: `vpus_per_gb = 10` (Balanced tier, included in Free Tier). The "Lower Cost" tier (`vpus_per_gb = 0`) was removed in OCI provider v8.0.0.
- **Public IP via reserved IP**: The instance is created with `assign_public_ip = false`; instead, a reserved IP is looked up via a `data.oci_core_private_ips` data source and attached as `oci_core_public_ip`.

### Startup Script (`scripts/startup.sh`) — Two-Phase Architecture

The startup script uses a two-phase architecture to solve a timing race: Terraform creates the `volume_attachment` only AFTER the instance reaches RUNNING state, but cloud-init runs the startup script immediately on boot. A single-phase script cannot reliably wait for the block device because the attachment hasn't even started yet.

**Phase A** (runs inline via cloud-init — fast, no volume needed): Sets `DEBIAN_FRONTEND=noninteractive`, configures needrestart, adds Docker APT repo, installs all packages (Docker, tools) in a single `apt-get update` + install, adds user to docker group, configures additional SSH key. Then writes the Phase B script (`/opt/mnt-data-setup.sh`) and a systemd oneshot unit (`mnt-data-setup.service`), enables the service, and exits. Does NOT write the completion marker — Phase B does that. Uses a completion marker (`/var/log/.setup_script_completed`) to prevent re-runs of Phase A. Has retry logic for network operations. Uses APT lock timeout (`DPkg::Lock::Timeout=60`) to handle race conditions with `unattended-upgrades`.

**Phase B** (runs as `mnt-data-setup.service` — waits for volume): A `Type=oneshot` systemd service (`After=network-online.target docker.service`, `ConditionPathExists=!/var/log/.setup_script_completed`, `TimeoutStartSec=3900`). Auto-detects the secondary block device with **exponential backoff** (10s → 15s → 22s → ... → max 60s interval, 60-minute hard cap); fallback to `/dev/sdb` applies the same partition/mount safety checks. Skips detection/mount if `/mnt/data` is already mounted (idempotent re-run). Formats with lazy ext4 init for fast first-boot. Uses UUID-based fstab entries with retry logic for `blkid` (up to 10 attempts). After mount, creates a systemd override so Docker waits for `mnt-data.mount` on reboot (prevents containers from starting against an empty mount point). Optionally installs RunTipi (downloads installer to file, no `curl|bash`; skips if `$MNT_DIR/runtipi` exists), optionally installs Coolify (symlinks data to block volume with integrity validation — aborts if regular directory exists, aborts if symlink points to wrong target; skips installer if `.env` already exists; pre-configures admin credentials via environment variables — the Coolify installer requires all three of `ROOT_USERNAME`, `ROOT_USER_EMAIL`, `ROOT_USER_PASSWORD`; FQDN must be configured from the Coolify UI after installation; starts existing Coolify containers when installer is skipped; explicitly sets `AUTOUPDATE=true/false`; `coolify_admin_password` is embedded in `user_data`/state — marked `sensitive` but should be rotated after first login), and optionally configures WireGuard client (fully non-fatal: both `systemctl enable --now` and `wg show` are guarded). Writes the completion marker on success.

**Dependency chain**: `cloud-init` → Phase A (packages, Docker, writes service) → `mnt-data-setup.service` Phase B (waits for disk, mounts, apps) → on reboot: `mnt-data.mount` (fstab) → `docker.service` (override) → containers.

**Phase B is written as a quoted heredoc** (`<<'PHASE_B_EOF'`) inside `startup.sh`. Terraform's `templatefile()` interpolates `${VAR}` at plan time (before bash sees it), so template variables become literal values in the Phase B script. Bash variables use `$VAR` (no braces) and pass through Terraform untouched. Nested heredocs inside Phase B use distinct delimiters that don't conflict with the outer `PHASE_B_EOF`. Note: Phase B content is not shellcheck-validated at CI time (inside a quoted heredoc).

**Instance recreation**: if an instance is destroyed and recreated with the same block volume, both RunTipi and Coolify restart automatically — RunTipi via `./runtipi-cli start` (runs outside the installer guard), Coolify via `docker compose up -d` in the "already installed" branch. All `cd` commands use subshells to avoid leaking working directory.

**Runtime files created by startup**: `/opt/mnt-data-setup.sh` (Phase B script), `/etc/systemd/system/mnt-data-setup.service` (systemd unit), `/etc/systemd/system/docker.service.d/wait-for-mount.conf` (Docker mount override). Monitor Phase B progress: `journalctl -u mnt-data-setup.service -f`. Retry after failure: `systemctl restart mnt-data-setup.service`.

## CI/CD

Two GitHub Actions workflows (`.github/workflows/`):
- **terraform.yml**: Runs on push/PR to main and weekly. Builds the Docker test image, then runs fmt-check, validate, lint, shellcheck, and security scan. Format, validate, and shellcheck are blocking; lint and security use `continue-on-error`. Checks docs drift on PRs. Posts a results table as PR comment (updates existing comment). Uses concurrency control to cancel in-progress runs. A separate job uploads Trivy SARIF to GitHub Security tab.
- **documentation.yml**: Auto-generates terraform-docs on PRs when `.tf` files change.

## Dependencies

Renovate (`renovate.json`) auto-updates: OCI provider version in `versions.tf`, GitHub Actions versions, and Dockerfile tool versions (OpenTofu, terraform-docs, tflint, Trivy) via custom regex managers.

## Variables

Required (set in `terraform.tfvars` or `TF_VAR_*` env vars): `compartment_ocid`, `tenancy_ocid`, `user_ocid`, `oracle_api_key_fingerprint`, `ssh_public_key`. See `terraform.tfvars.template` for the format.

Notable optional: `install_runtipi` (default: `true`), `install_coolify` (default: `false`, mutually exclusive with `install_runtipi`), `coolify_admin_email`/`coolify_admin_password` (must both be set or both empty), `coolify_auto_update` (default: `true`), `coolify_admin_source_cidr` (default: `"0.0.0.0/0"` — restricts Coolify admin ports 8000, 6001-6002; HTTP/HTTPS for apps stay open), `enable_ping` (default: `false`), `ssh_source_cidr` (default: `"0.0.0.0/0"`), `custom_ingress_security_rules` (simplified: protocol + ports + source, all validated), `enable_unrestricted_egress` (default: `true` — all outbound allowed; set to `false` for restrictive egress), `egress_security_rules` (only used when unrestricted egress is disabled), `wireguard_client_configuration` (must start with `[Interface]` or be empty), `kms_key_id` for volume encryption, `freeform_tags` (default: `{ManagedBy=Terraform}`).
