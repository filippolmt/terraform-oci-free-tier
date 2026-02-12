# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Terraform module for deploying Oracle Cloud Infrastructure (OCI) Free Tier resources. Provisions an ARM-based VM (VM.Standard.A1.Flex) with Docker, optional RunTipi homeserver, and optional WireGuard VPN client.

**Current version: 4.0.0** - See [CHANGELOG.md](CHANGELOG.md) for breaking changes from v3.x.

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
- **`ignore_changes` on user_data**: The instance in `compute.tf` has `lifecycle { ignore_changes = [metadata["user_data"]] }` to prevent instance recreation when the startup script changes.
- **Startup script is a `templatefile()`**: `scripts/startup.sh` is rendered via `templatefile()` in the instance's `user_data` metadata block in `compute.tf`. Any new shell variable in the script must have a matching Terraform variable passed in the `templatefile()` call. Existing template variables: `ADDITIONAL_SSH_PUB_KEY`, `INSTALL_RUNTIPI`, `RUNTIPI_REVERSE_PROXY_IP`, `RUNTIPI_MAIN_NETWORK_SUBNET`, `RUNTIPI_ADGUARD_IP`, `WIREGUARD_CLIENT_CONFIGURATION`.
- **Free Tier validation rules**: `variables.tf` includes validation blocks that enforce Free Tier limits (max 4 OCPUs, max 24GB RAM, minimum volume sizes, CIDR format, fault domain format).
- **Region image OCIDs**: `variables.tf` contains a `instance_image_ocids_by_region` map with Ubuntu 24.04 ARM64 image OCIDs for 35+ OCI regions. When updating the base image, every region OCID must be updated. These are managed by Renovate when possible.
- **Ingress firewall rules**: Managed via `locals` in `network.tf`. SSH (22/TCP, source configurable via `ssh_source_cidr`) and ICMP fragmentation (type 3, code 4) are always enabled. HTTP (80), HTTPS (443), and WireGuard (51820/UDP) are auto-added when `install_runtipi = true`. Ping is controlled by `enable_ping` (default: false). Custom rules use `custom_ingress_security_rules` with a simplified type (protocol + ports + source, all validated). OCI protocol identifiers: `"6"` = TCP, `"17"` = UDP, `"1"` = ICMP.
- **Egress firewall rules**: Controlled by `enable_unrestricted_egress` (default: `true` — all outbound traffic allowed). When `false`, only `egress_security_rules` are applied (default: HTTPS, HTTP, DNS, NTP).
- **Block volume performance**: `vpus_per_gb = 10` (Balanced tier, included in Free Tier). The "Lower Cost" tier (`vpus_per_gb = 0`) was removed in OCI provider v8.0.0.
- **Public IP via reserved IP**: The instance is created with `assign_public_ip = false`; instead, a reserved IP is looked up via a `data.oci_core_private_ips` data source and attached as `oci_core_public_ip`.

### Startup Script (`scripts/startup.sh`)

Runs via cloud-init on first boot. Uses a completion marker (`/var/log/.setup_script_completed`) to prevent re-runs. Sets `DEBIAN_FRONTEND=noninteractive` to avoid apt hangs. Uses APT lock timeout (`DPkg::Lock::Timeout=60`) to handle race conditions with `unattended-upgrades`. Adds Docker APT repo first, then does a single `apt-get update` + install for all packages. Has retry logic for network operations. Auto-detects the secondary block device with a retry loop (up to 5 minutes) for volume attachment; fallback to `/dev/sdb` applies the same partition/mount safety checks as the main loop. Formats with lazy ext4 init for fast first-boot. Uses UUID-based fstab entries with retry logic for `blkid` (up to 10 attempts). Installs Docker, optionally installs RunTipi (downloads installer to file, no `curl|bash`), and optionally configures WireGuard client (fully non-fatal: both `systemctl enable --now` and `wg show` are guarded).

## CI/CD

Two GitHub Actions workflows (`.github/workflows/`):
- **terraform.yml**: Runs on push/PR to main and weekly. Builds the Docker test image, then runs fmt-check, validate, lint, shellcheck, and security scan. Format, validate, and shellcheck are blocking; lint and security use `continue-on-error`. Checks docs drift on PRs. Posts a results table as PR comment (updates existing comment). Uses concurrency control to cancel in-progress runs. A separate job uploads Trivy SARIF to GitHub Security tab.
- **documentation.yml**: Auto-generates terraform-docs on PRs when `.tf` files change.

## Dependencies

Renovate (`renovate.json`) auto-updates: OCI provider version in `versions.tf`, GitHub Actions versions, and Dockerfile tool versions (OpenTofu, terraform-docs, tflint, Trivy) via custom regex managers.

## Variables

Required (set in `terraform.tfvars` or `TF_VAR_*` env vars): `compartment_ocid`, `tenancy_ocid`, `user_ocid`, `oracle_api_key_fingerprint`, `ssh_public_key`. See `terraform.tfvars.template` for the format.

Notable optional: `install_runtipi` (default: `true`), `enable_ping` (default: `false`), `ssh_source_cidr` (default: `"0.0.0.0/0"`), `custom_ingress_security_rules` (simplified: protocol + ports + source, all validated), `enable_unrestricted_egress` (default: `true` — all outbound allowed; set to `false` for restrictive egress), `egress_security_rules` (only used when unrestricted egress is disabled), `wireguard_client_configuration` (must start with `[Interface]` or be empty), `kms_key_id` for volume encryption, `freeform_tags` (default: `{ManagedBy=Terraform}`).
