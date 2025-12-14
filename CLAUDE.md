# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Terraform module for deploying Oracle Cloud Infrastructure (OCI) Free Tier resources. Provisions an ARM-based VM (VM.Standard.A1.Flex) with Docker, optional RunTipi homeserver, and optional WireGuard VPN client.

**Current version: 3.0.0** - See [CHANGELOG.md](CHANGELOG.md) for breaking changes from v2.x.

## Common Commands

```bash
# Initialize
terraform init    # or: tofu init

# Plan and apply
terraform plan    # or: tofu plan
terraform apply   # or: tofu apply

# Destroy
terraform destroy # or: tofu destroy

# Validate
terraform validate # or: tofu validate
```

## Local Testing (Docker)

```bash
# Run all tests (fmt, validate, lint, security)
make test

# Individual targets
make build          # Build Docker image
make fmt            # Format Terraform files
make fmt-check      # Check formatting
make validate       # Run tofu validate
make lint           # Run tflint
make security       # Run Trivy (HIGH/CRITICAL only)
make security-all   # Run Trivy (all severities)
make docs           # Generate terraform-docs
make shell          # Interactive shell in container
make clean          # Remove Docker image and .terraform

# Native targets (without Docker, requires local tools)
make native-test
```

## Architecture

### Resources Created
- **VCN** with configurable subnet CIDR, internet gateway, and security list
- **Compute Instance**: ARM64 VM (default: 4 OCPUs, 24GB RAM) running Ubuntu 24.04 Minimal
- **Block Volume**: Separate volume for Docker data (default: 150GB) mounted at `/mnt/data` with `prevent_destroy` lifecycle
- **Reserved Public IP**: Persistent IP attached to the instance
- **Backup Policy**: Daily incremental backups with 5-day retention

### Key Files
- `versions.tf`: Terraform/OpenTofu and provider version constraints
- `providers.tf`: OCI provider configuration
- `main.tf`: All infrastructure resources
- `variables.tf`: Input variables with OCI image OCIDs for all regions
- `outputs.tf`: Instance, network, and volume outputs including SSH connection string
- `scripts/startup.sh`: Cloud-init script for Docker, RunTipi, and WireGuard setup
- `Dockerfile`: Multi-arch container with OpenTofu, tflint, Trivy, terraform-docs
- `Makefile`: Test automation (Docker and native targets)
- `renovate.json`: Automated dependency updates configuration
- `CHANGELOG.md`: Version history and breaking changes documentation
- `.trivyignore`: Security scan exceptions for CI/CD container

### Startup Script Features
The instance runs `scripts/startup.sh` via cloud-init which:
1. Uses completion marker (`/var/log/.setup_script_completed`) to prevent re-runs
2. Has retry logic for network operations (apt-get, curl)
3. Auto-detects secondary block device (not hardcoded)
4. Installs Docker and adds ubuntu user to docker group
5. Formats and mounts the block volume at `/mnt/data`
6. If `install_runtipi=true`: Downloads and installs RunTipi (no curl|bash)
7. If `wireguard_client_configuration` is provided: Installs WireGuard client

### Security Configuration

**Ingress rules** (`ingress_security_rules` variable):
- TCP 22 (SSH) - "Allow SSH from anywhere"
- UDP 51820 (WireGuard) - "Allow WireGuard VPN"
- ICMP type 3 code 4 - "Allow ICMP fragmentation needed"

**Egress rules** (`egress_security_rules` variable) - restrictive defaults:
- TCP 443 (HTTPS outbound)
- TCP 80 (HTTP outbound)
- UDP/TCP 53 (DNS outbound)
- UDP 123 (NTP outbound)

All security rules have descriptions and are fully configurable via variables.

### Resource Tagging
All resources support `freeform_tags` variable (default: `ManagedBy=Terraform`).

### Encryption
Optional KMS encryption via `kms_key_id` variable for boot volume and docker volume.

## CI/CD Workflows

- **documentation.yml**: Auto-generates terraform-docs on PRs (only runs when .tf files change)
- **terraform.yml**: Runs on push/PR to main and weekly, uses Makefile targets:
  - `make fmt-check` - Format validation
  - `make validate` - OpenTofu validation
  - `make lint` - tflint analysis
  - `make security` - Trivy security scan (HIGH/CRITICAL)
  - Posts PR comment with results summary
  - Uploads Trivy SARIF to GitHub Security tab

## Dependency Management

Renovate is configured (`renovate.json`) to automatically update:
- Terraform/OCI provider versions
- GitHub Actions versions
- Dockerfile tool versions (OpenTofu, terraform-docs, tflint, Trivy)

## Required Variables

Set these in `terraform.tfvars` or as `TF_VAR_*` environment variables:
- `compartment_ocid`
- `tenancy_ocid`
- `user_ocid`
- `oracle_api_key_fingerprint`
- `ssh_public_key`

## Optional Variables

- `subnet_cidr_block`: Subnet CIDR (default: `10.1.0.0/24`)
- `kms_key_id`: KMS key for volume encryption (default: `null`)
- `freeform_tags`: Tags for all resources (default: `{ManagedBy=Terraform}`)
- `ingress_security_rules`: Inbound firewall rules
- `egress_security_rules`: Outbound firewall rules (restrictive by default)

## Outputs

- `instance_id`, `private_ip`, `public_ip`
- `vcn_id`, `subnet_id`, `docker_volume_id`
- `availability_domain`
- `ssh_connection` - Ready-to-use SSH command
