# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.1.0] - 2026-02-17

### Added

- **Input Validations:**
  - `region` — validated against the 37 supported regions in `instance_image_ocids_by_region` (clear error instead of cryptic map lookup failure)
  - `instance_display_name` — validated for OCI hostname label constraints (alphanumeric + hyphens, starts with letter, max 63 chars)
  - `runtipi_main_network_subnet` — CIDR format validation (consistent with `vcn_cidr_block` / `subnet_cidr_block`)
  - `runtipi_reverse_proxy_ip` / `runtipi_adguard_ip` — IPv4 format validation
  - `oracle_api_key_fingerprint` / `ssh_public_key` — added `nullable = false` to catch `null` values early
- **Egress + WireGuard warning** in `enable_unrestricted_egress` description: reminds users to add outbound UDP rule when using WireGuard with restrictive egress

### Changed

- **Ingress rules refactored to uniform for-expression pattern** — all four rule groups (`base_ingress_rules`, `ping_ingress_rule`, `runtipi_ingress_rules`, `custom_ingress_rules`) now use the same compact for-expression with per-field conditionals, eliminating verbose null-field repetition and avoiding OpenTofu tuple-to-list type-unification errors
- **`terraform.tfvars.template`** — converted from `TF_VAR_*` env-var format to proper HCL `.tfvars` format with comments explaining where to find each value in the OCI Console
- **`versions.tf`** — removed stale leading blank line

### Removed

- Empty `modules/resources/` directory (legacy artifact)

## [4.0.0] - 2026-02-12

### Breaking Changes

#### Ingress Security Rules Redesigned

The `ingress_security_rules` variable has been **removed**. Firewall rules are now managed via smart defaults + a simplified custom variable.

**Before (v3.x):**
```hcl
# Required specifying the full complex object for every rule
ingress_security_rules = [
  {
    description = "Allow SSH"
    protocol    = "6"
    source      = "0.0.0.0/0"
    stateless   = false
    tcp_options = {
      source_port_range = { min = 1, max = 65535 }
      min = 22
      max = 22
    }
    udp_options  = null
    icmp_options = null
  }
]
```

**After (v4.0):**
```hcl
# SSH and ICMP are always enabled automatically
# HTTP (80), HTTPS (443), WireGuard (51820/UDP) are auto-added when install_runtipi = true
# Ping is controlled by enable_ping (default: false)

# To add custom ports, use the simplified variable:
custom_ingress_security_rules = [
  {
    description = "Allow Minecraft"
    protocol    = "6"       # "6" (TCP) or "17" (UDP)
    port_min    = 25565
    port_max    = 25565
    # source defaults to "0.0.0.0/0", description defaults to "Custom rule"
  }
]
```

**Migration:**
1. Remove `ingress_security_rules` from your `terraform.tfvars`
2. SSH, ICMP, and RunTipi-related ports are now automatic — no need to declare them
3. Move any non-standard ports to `custom_ingress_security_rules` using the simplified format
4. If you had ping rules, set `enable_ping = true`

#### Egress Security Rules Type Simplified

The `egress_security_rules` type has been simplified: `source_port_range` removed (was always "any"), and `tcp_options`/`udp_options`/`icmp_options` are now `optional()`.

**Before (v3.x):**
```hcl
egress_security_rules = [
  {
    description      = "Allow HTTPS outbound"
    protocol         = "6"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    stateless        = false
    tcp_options = {
      source_port_range = { min = 1, max = 65535 }
      min = 443
      max = 443
    }
    udp_options  = null
    icmp_options = null
  }
]
```

**After (v4.0):**
```hcl
egress_security_rules = [
  {
    description      = "Allow HTTPS outbound"
    protocol         = "6"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    stateless        = false
    tcp_options      = { min = 443, max = 443 }
    # udp_options and icmp_options can be omitted (optional)
  }
]
```

**Migration:** Remove `source_port_range` blocks and `null` option fields from your egress rules.

#### Variable Types Changed from String to Number

The following variables changed type from `string` to `number`:
- `instance_shape_config_memory_gb` (default: `24`)
- `instance_shape_config_ocpus` (default: `4`)
- `instance_shape_boot_volume_size_gb` (default: `50`)
- `docker_volume_size_gb` (default: `150`)

**Migration:** Remove quotes around numeric values in your `terraform.tfvars`:
```hcl
# Before
instance_shape_config_ocpus = "4"
# After
instance_shape_config_ocpus = 4
```

### State Migration

**No `tofu state mv` commands are needed.** The `main.tf` file was split into `network.tf`, `compute.tf`, and `storage.tf`, but all resource names are unchanged. OpenTofu tracks resources by type+name (e.g., `oci_core_vcn.vcn`), not by filename.

### Added

- **New Variables:**
  - `enable_ping` - Allow ICMP echo requests (default: `false`)
  - `ssh_source_cidr` - Restrict SSH access to specific CIDR (default: `0.0.0.0/0`)
  - `enable_unrestricted_egress` - Allow all outbound traffic (default: `true`). Set to `false` to apply restrictive `egress_security_rules`
  - `custom_ingress_security_rules` - Simplified custom ingress rules (protocol + ports + source, all validated)
- **Input Validation:**
  - `custom_ingress_security_rules`: protocol must be `"6"` or `"17"`, ports 1-65535, `port_min <= port_max`, source must be valid CIDR
  - `ssh_source_cidr`: must be valid CIDR notation
- **New Output:**
  - `security_list_id` - Security list OCID
- **Free Tier Validations:**
  - OCPUs: 1-4 (VM.Standard.A1.Flex limit)
  - RAM: 1-24 GB
  - Boot volume: minimum 50 GB
  - Block volume: minimum 50 GB
  - Availability domain: 1-3
  - Fault domain: FAULT-DOMAIN-1/2/3
  - VCN and subnet CIDR: valid notation
- **CI/CD:**
  - Shellcheck step for `scripts/*.sh` validation
  - Documentation drift check on PRs (`make docs-check`)
  - Concurrency control (cancels in-progress runs on same branch)
  - PR comments are updated instead of creating duplicates

### Changed

- **File Organization:** `main.tf` split into `network.tf`, `compute.tf`, `storage.tf` for readability
- **Compute Instance:** Added `lifecycle { ignore_changes = [metadata["user_data"]] }` to prevent instance recreation when startup script changes
- **Block Volume:** Changed `vpus_per_gb` from `0` (Lower Cost, removed in OCI provider v8.0.0) to `10` (Balanced, included in Free Tier). Removed `autotune_policies` block.
- **Backup Policy:** Reduced retention from 5 days to 3 days (Free Tier allows only 5 total backups across boot + block volumes)
- **Route Table:** Added `freeform_tags` to `oci_core_default_route_table` for consistency with all other resources
- **CI/CD:** Added `per_page: 100` to PR comment lookup to handle PRs with many comments
- **Dockerfile:** Refactored to multi-stage build (build tools excluded from final image, ~40% smaller)
- **Tool Versions:** Trivy 0.69.1, tflint 0.61.0

### Fixed

- **Startup Script — Ubuntu 24.04 Minimal Compatibility:**
  - Replaced `gpg --dearmor` with direct `.asc` key (gpg binary not available in Ubuntu Minimal)
  - Removed `gnupg` from package install (no longer needed)
- **Startup Script — Disk Mount on First Boot:**
  - Changed `mkfs.ext4` to lazy inode/journal init (was blocking for minutes on 150GB volumes)
  - Added 30-attempt retry loop for block device detection (volume attachment may be in progress)
  - Fixed fallback `/dev/sdb` logic: now applies same partition/mount safety checks as the detection loop
  - Added UUID retry loop (up to 10 attempts) for `blkid` after `mkfs` with lazy init
- **Startup Script — APT Reliability:**
  - Added `DEBIAN_FRONTEND=noninteractive` to prevent interactive prompts
  - Added `DPkg::Lock::Timeout=60` to all apt-get commands (race with unattended-upgrades)
  - Added `--force-confdef --force-confold` to apt-get upgrade (non-interactive config handling)
  - Consolidated to single `apt-get update` (Docker repo added first, then one update for everything)
- **Startup Script — Mount Stability:**
  - Changed fstab from device path (`/dev/sdb`) to UUID-based entries (device paths can change between reboots)
- **Startup Script — WireGuard:**
  - Made WireGuard fully non-fatal: both `systemctl enable --now` and `wg show` are guarded against `set -e`
- **Ubuntu Image OCIDs:** Updated all 36 regions to latest 2025.10.31 release

## [3.0.0] - 2025-12-15

### Breaking Changes

#### Security List Rules Restructured

**Before (v2.x):**
```hcl
variable "security_list_rules" {
  type = list(object({
    protocol = string
    port     = number
    source   = string
  }))
}
```

**After (v3.0):**
```hcl
variable "ingress_security_rules" {
  type = list(object({
    protocol    = string
    port        = number
    source      = string
    description = string  # NEW: required field
  }))
}

variable "egress_security_rules" {
  type = list(object({
    protocol    = string
    port        = number
    destination = string
    description = string
  }))
}
```

**Migration:**
1. Rename `security_list_rules` to `ingress_security_rules` in your `terraform.tfvars`
2. Add `description` field to each rule
3. Review egress rules - defaults are now **restrictive** (only HTTPS, HTTP, DNS, NTP)

**Example migration:**
```hcl
# Old (v2.x)
security_list_rules = [
  { protocol = "tcp", port = 22, source = "0.0.0.0/0" },
  { protocol = "tcp", port = 80, source = "0.0.0.0/0" },
]

# New (v3.0)
ingress_security_rules = [
  { protocol = "tcp", port = 22, source = "0.0.0.0/0", description = "Allow SSH" },
  { protocol = "tcp", port = 80, source = "0.0.0.0/0", description = "Allow HTTP" },
]

# If you need additional egress rules beyond defaults:
egress_security_rules = [
  { protocol = "tcp", port = 443, destination = "0.0.0.0/0", description = "HTTPS outbound" },
  { protocol = "tcp", port = 80, destination = "0.0.0.0/0", description = "HTTP outbound" },
  { protocol = "udp", port = 53, destination = "0.0.0.0/0", description = "DNS outbound" },
  { protocol = "tcp", port = 53, destination = "0.0.0.0/0", description = "DNS outbound TCP" },
  { protocol = "udp", port = 123, destination = "0.0.0.0/0", description = "NTP outbound" },
  # Add your custom rules here
]
```

#### Removed Data Sources

The following unused data sources have been removed:
- `data.oci_core_vnic_attachments.instance_vnics`
- `data.oci_core_vnic.instance_vnic`

If you were referencing these in external configurations, use the new outputs instead.

### Added

- **New Variables:**
  - `subnet_cidr_block` - Configure subnet CIDR (default: `10.1.0.0/24`)
  - `kms_key_id` - Optional KMS key for volume encryption
  - `freeform_tags` - Tags applied to all resources (default: `{ManagedBy = "Terraform"}`)
  - `egress_security_rules` - Configurable outbound firewall rules

- **New Outputs:**
  - `vcn_id` - VCN OCID
  - `subnet_id` - Subnet OCID
  - `docker_volume_id` - Docker volume OCID
  - `availability_domain` - Deployment availability domain
  - `ssh_connection` - Ready-to-use SSH command

- **Local Testing Infrastructure:**
  - `Dockerfile` - Multi-arch container with OpenTofu, tflint, Trivy, terraform-docs
  - `Makefile` - Test automation (`make test`, `make lint`, `make security`, etc.)
  - `.trivyignore` - Security scan exceptions for CI/CD container

- **Dependency Management:**
  - `renovate.json` - Automated updates for providers, GitHub Actions, and Dockerfile tools

### Changed

- **Provider Configuration:** Moved to dedicated `providers.tf` file (best practice)
- **GitHub Actions:**
  - Replaced deprecated `tfsec` with Trivy
  - Now uses Makefile targets for consistency between local and CI
  - Posts detailed PR comments with test results
  - Uploads SARIF to GitHub Security tab
- **Variable Descriptions:** All variables now have clear, detailed descriptions
- **Docker Volume:** Added `lifecycle { prevent_destroy = true }` for data protection

### Improved

- **Startup Script (`scripts/startup.sh`):**
  - Added completion marker to prevent re-runs on reboot
  - Added retry logic for network operations (apt-get, curl)
  - Auto-detects block device instead of hardcoded `/dev/sdb`
  - Improved security: downloads scripts before executing (no curl|bash)
  - Fixed shellcheck warnings (proper variable quoting)
  - Added error handling with cleanup trap

### Security

- **Restrictive Egress by Default:** New deployments only allow outbound HTTPS, HTTP, DNS, and NTP
- **Security Rule Descriptions:** All firewall rules now require descriptions for audit trails
- **KMS Encryption Support:** Optional customer-managed encryption for volumes

## [2.5.0] and earlier

See [GitHub Releases](https://github.com/filippomerante/terraform-oci-free-tier/releases) for previous versions.
