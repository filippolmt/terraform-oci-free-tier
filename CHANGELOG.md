# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
