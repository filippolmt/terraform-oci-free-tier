# Terraform OCI Free Tier

This repository provides OpenTofu/Terraform configurations for deploying resources in the Oracle Cloud Infrastructure (OCI) Free Tier.

> **Upgrading from v3.x or v2.x?** See the [CHANGELOG](CHANGELOG.md) for breaking changes and migration guide.

## Table of Contents

- [Terraform OCI Free Tier](#terraform-oci-free-tier)
  - [Table of Contents](#table-of-contents)
  - [Changelog](#changelog)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
  - [Usage](#usage)
  - [Files](#files)
  - [Security Configuration](#security-configuration)
  - [RunTipi Configuration](#runtipi-configuration)
  - [License](#license)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history, breaking changes, and migration guides.

## Prerequisites

- [OpenTofu](https://opentofu.org/docs/intro/install/) (recommended) or [Terraform](https://developer.hashicorp.com/terraform/install) installed on your local machine.
- An Oracle Cloud Infrastructure (OCI) account.
- OCI CLI configured with your credentials.

## Setup

1. **Clone the repository**:
    ```bash
    git clone https://github.com/filippolmt/terraform-oci-free-tier.git
    cd terraform-oci-free-tier
    ```

2. **Configure your variables**:
    Copy the `terraform.tfvars.template` to `terraform.tfvars` and fill in the required variables.
    By default, the `install_runtipi` variable is set to `true`, which will trigger the installation of RunTipi. If you do not wish to install RunTipi, set this variable to `false`.
    ```bash
    cp terraform.tfvars.template terraform.tfvars
    ```

3. **Initialize Terraform or OpenTofu**:
    Depending on the tool you are using, run:
    ```bash
    terraform init
    ```
    or
    ```bash
    tofu init
    ```

## Usage

1. **Plan the deployment**:
    ```bash
    terraform plan
    ```
    or
    ```bash
    tofu plan
    ```

2. **Apply the deployment**:
    ```bash
    terraform apply
    ```
    or
    ```bash
    tofu apply
    ```

3. **Destroy the deployment**:
    ```bash
    terraform destroy
    ```
    or
    ```bash
    tofu destroy
    ```

## Files

- `versions.tf`: Specifies the required Terraform/OpenTofu version and provider versions.
- `providers.tf`: OCI provider configuration.
- `network.tf`: Networking resources (VCN, Subnet, Internet Gateway, Route Table, Security List).
- `compute.tf`: Compute resources (Instance, Public IP, data sources).
- `storage.tf`: Storage resources (Block Volume, Volume Attachment, Backup Policy).
- `variables.tf`: Defines the variables used in the Terraform configuration. Includes Free Tier validation rules for OCPUs, RAM, and volume sizes.
- `outputs.tf`: Defines the outputs of the Terraform configuration.
- `terraform.tfvars.template`: Template for user-specific variables.
- `scripts/startup.sh`: Cloud-init script for initial setup. Features:
    - Completion marker to prevent re-runs on reboot
    - Retry logic for network operations and block volume attachment
    - Auto-detects secondary block device with retry loop
    - UUID-based fstab entries for reliable mounts across reboots
    - APT lock timeout handling to avoid race conditions with unattended-upgrades
    - Installs Docker and RunTipi (if enabled)
    - Configures WireGuard client (if provided, non-fatal on failure)
- `.github/workflows/`: Contains GitHub Actions workflows for CI/CD.
    - `documentation.yml`: Auto-generates terraform-docs on PRs.
    - `terraform.yml`: Runs fmt-check, validate, lint, shellcheck, security scan, and docs-check on PRs.

## Security Configuration

Ingress firewall rules are managed automatically based on enabled features. No manual configuration is needed for common use cases.

### Ingress Rules

**Always enabled:**
- TCP 22 (SSH) — source configurable via `ssh_source_cidr` (default: `0.0.0.0/0`)
- ICMP type 3 code 4 (fragmentation needed — required for Path MTU Discovery)

**Auto-added when `install_runtipi = true`:**
- TCP 80 (HTTP)
- TCP 443 (HTTPS)
- UDP 51820 (WireGuard)

**Optional:**
- ICMP ping: set `enable_ping = true` (default: `false`)

**Custom rules** — use `custom_ingress_security_rules` with a simplified format:
```hcl
custom_ingress_security_rules = [
  {
    description = "Allow Minecraft"
    protocol    = "6"       # "6" (TCP) or "17" (UDP)
    port_min    = 25565
    port_max    = 25565
    # source defaults to "0.0.0.0/0"
  }
]
```

### Egress Rules

By default, all outbound traffic is allowed (`enable_unrestricted_egress = true`). To apply restrictive egress rules, set `enable_unrestricted_egress = false` — the default restrictive set allows only:
- TCP 443 (HTTPS)
- TCP 80 (HTTP)
- UDP/TCP 53 (DNS)
- UDP 123 (NTP)

To further customize restrictive egress rules, override `egress_security_rules`.

### Optional Features
- **KMS Encryption**: Set `kms_key_id` to encrypt boot and data volumes with customer-managed keys
- **Resource Tagging**: All resources are tagged with `freeform_tags` (default: `ManagedBy=Terraform`)

## RunTipi Configuration

If `install_runtipi` is set to `true`, the setup script will install RunTipi and configure the local network for running applications within the local domain. Follow these steps to correctly configure RunTipi:

1. **Access RunTipi via Public IP**:
    - Install AdGuard from the RunTipi apps.
    - In the "Network Interface" section, add the IP `127.0.0.1` and ensure the system is also reachable from the internet.
    - Add a valid DNS or any DNS by modifying the `hosts` file if needed.

2. **Configure DNS Resolution for VPN Network**:
    - Access the RunTipi dashboard and follow this guide for DNS resolution within the VPN network: [RunTipi DNS Resolution Guide](https://runtipi.io/docs/guides/local-certificate#dns-resolution).
    - Configure the IP to `172.18.0.254`, which is the IP set for Traefik.

3. **Configure WireGuard**:
    - Install and configure WireGuard by adding a public IP or DNS.
    - Set a password and configure the AdGuard IP to `172.18.0.253`.
    - Restart RunTipi.

4. **Disable Internet Access**:
    - Once AdGuard is configured and running, you can disable internet access to ensure that applications are only reachable within the local network.

Once these steps are complete, you will be able to use the local network without the applications being accessible externally.

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | 8.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | 8.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_core_default_route_table.default_route_table](https://registry.terraform.io/providers/oracle/oci/8.0.0/docs/resources/core_default_route_table) | resource |
| [oci_core_instance.instance](https://registry.terraform.io/providers/oracle/oci/8.0.0/docs/resources/core_instance) | resource |
| [oci_core_internet_gateway.internet_gateway](https://registry.terraform.io/providers/oracle/oci/8.0.0/docs/resources/core_internet_gateway) | resource |
| [oci_core_public_ip.public_ip](https://registry.terraform.io/providers/oracle/oci/8.0.0/docs/resources/core_public_ip) | resource |
| [oci_core_security_list.security_list](https://registry.terraform.io/providers/oracle/oci/8.0.0/docs/resources/core_security_list) | resource |
| [oci_core_subnet.subnet](https://registry.terraform.io/providers/oracle/oci/8.0.0/docs/resources/core_subnet) | resource |
| [oci_core_vcn.vcn](https://registry.terraform.io/providers/oracle/oci/8.0.0/docs/resources/core_vcn) | resource |
| [oci_core_volume.docker_volume](https://registry.terraform.io/providers/oracle/oci/8.0.0/docs/resources/core_volume) | resource |
| [oci_core_volume_attachment.docker_volume_attachment](https://registry.terraform.io/providers/oracle/oci/8.0.0/docs/resources/core_volume_attachment) | resource |
| [oci_core_volume_backup_policy.docker_volume_backup_policy](https://registry.terraform.io/providers/oracle/oci/8.0.0/docs/resources/core_volume_backup_policy) | resource |
| [oci_core_volume_backup_policy_assignment.docker_volume_backup_policy_assignment](https://registry.terraform.io/providers/oracle/oci/8.0.0/docs/resources/core_volume_backup_policy_assignment) | resource |
| [oci_core_private_ips.instance_private_ip](https://registry.terraform.io/providers/oracle/oci/8.0.0/docs/data-sources/core_private_ips) | data source |
| [oci_identity_availability_domain.ad](https://registry.terraform.io/providers/oracle/oci/8.0.0/docs/data-sources/identity_availability_domain) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_ssh_public_key"></a> [additional\_ssh\_public\_key](#input\_additional\_ssh\_public\_key) | Additional SSH public key to add to authorized\_keys (optional) | `string` | `""` | no |
| <a name="input_availability_domain_number"></a> [availability\_domain\_number](#input\_availability\_domain\_number) | The availability domain number (1-3 depending on region) | `number` | `1` | no |
| <a name="input_compartment_ocid"></a> [compartment\_ocid](#input\_compartment\_ocid) | The OCID of the compartment | `string` | n/a | yes |
| <a name="input_custom_ingress_security_rules"></a> [custom\_ingress\_security\_rules](#input\_custom\_ingress\_security\_rules) | Additional custom ingress rules. SSH (22/TCP) and ICMP fragmentation are always enabled. HTTP (80), HTTPS (443), and WireGuard (51820/UDP) are auto-added when install\_runtipi=true. Ping is controlled by enable\_ping. | <pre>list(object({<br/>    description = optional(string, "Custom rule")<br/>    protocol    = string # "6" (TCP) or "17" (UDP)<br/>    source      = optional(string, "0.0.0.0/0")<br/>    port_min    = number<br/>    port_max    = number<br/>  }))</pre> | `[]` | no |
| <a name="input_docker_volume_size_gb"></a> [docker\_volume\_size\_gb](#input\_docker\_volume\_size\_gb) | The size of the secondary block volume in GBs (mounted at /mnt/data for Docker data) | `number` | `150` | no |
| <a name="input_egress_security_rules"></a> [egress\_security\_rules](#input\_egress\_security\_rules) | List of egress (outbound) security rules. Only used when enable\_unrestricted\_egress=false. Default allows HTTP, HTTPS, DNS, and NTP. | <pre>list(object({<br/>    description      = string<br/>    protocol         = string<br/>    destination      = string<br/>    destination_type = string<br/>    stateless        = bool<br/>    tcp_options = optional(object({<br/>      min = number<br/>      max = number<br/>    }))<br/>    udp_options = optional(object({<br/>      min = number<br/>      max = number<br/>    }))<br/>    icmp_options = optional(object({<br/>      type = number<br/>      code = number<br/>    }))<br/>  }))</pre> | <pre>[<br/>  {<br/>    "description": "Allow HTTPS outbound",<br/>    "destination": "0.0.0.0/0",<br/>    "destination_type": "CIDR_BLOCK",<br/>    "protocol": "6",<br/>    "stateless": false,<br/>    "tcp_options": {<br/>      "max": 443,<br/>      "min": 443<br/>    }<br/>  },<br/>  {<br/>    "description": "Allow HTTP outbound",<br/>    "destination": "0.0.0.0/0",<br/>    "destination_type": "CIDR_BLOCK",<br/>    "protocol": "6",<br/>    "stateless": false,<br/>    "tcp_options": {<br/>      "max": 80,<br/>      "min": 80<br/>    }<br/>  },<br/>  {<br/>    "description": "Allow DNS outbound (UDP)",<br/>    "destination": "0.0.0.0/0",<br/>    "destination_type": "CIDR_BLOCK",<br/>    "protocol": "17",<br/>    "stateless": false,<br/>    "udp_options": {<br/>      "max": 53,<br/>      "min": 53<br/>    }<br/>  },<br/>  {<br/>    "description": "Allow DNS outbound (TCP)",<br/>    "destination": "0.0.0.0/0",<br/>    "destination_type": "CIDR_BLOCK",<br/>    "protocol": "6",<br/>    "stateless": false,<br/>    "tcp_options": {<br/>      "max": 53,<br/>      "min": 53<br/>    }<br/>  },<br/>  {<br/>    "description": "Allow NTP outbound",<br/>    "destination": "0.0.0.0/0",<br/>    "destination_type": "CIDR_BLOCK",<br/>    "protocol": "17",<br/>    "stateless": false,<br/>    "udp_options": {<br/>      "max": 123,<br/>      "min": 123<br/>    }<br/>  }<br/>]</pre> | no |
| <a name="input_enable_ping"></a> [enable\_ping](#input\_enable\_ping) | Whether to allow ICMP echo requests (ping) from anywhere | `bool` | `false` | no |
| <a name="input_enable_unrestricted_egress"></a> [enable\_unrestricted\_egress](#input\_enable\_unrestricted\_egress) | Allow all outbound traffic (all protocols, all ports, 0.0.0.0/0). When false, only egress\_security\_rules are applied. | `bool` | `true` | no |
| <a name="input_fault_domain"></a> [fault\_domain](#input\_fault\_domain) | The fault domain for the instance (FAULT-DOMAIN-1, FAULT-DOMAIN-2, or FAULT-DOMAIN-3) | `string` | `"FAULT-DOMAIN-2"` | no |
| <a name="input_freeform_tags"></a> [freeform\_tags](#input\_freeform\_tags) | Freeform tags to apply to all resources | `map(string)` | <pre>{<br/>  "ManagedBy": "Terraform"<br/>}</pre> | no |
| <a name="input_install_runtipi"></a> [install\_runtipi](#input\_install\_runtipi) | Whether to install RunTipi homeserver (https://runtipi.io) | `bool` | `true` | no |
| <a name="input_instance_display_name"></a> [instance\_display\_name](#input\_instance\_display\_name) | The display name of the instance | `string` | `"DockerHost"` | no |
| <a name="input_instance_image_ocids_by_region"></a> [instance\_image\_ocids\_by\_region](#input\_instance\_image\_ocids\_by\_region) | Map of OCI region to Ubuntu 24.04 ARM64 image OCID | `map(string)` | <pre>{<br/>  "af-johannesburg-1": "ocid1.image.oc1.af-johannesburg-1.aaaaaaaac74zk4rm447grg5rmu6ex2xj2sipgue2y26jpvquwxyfw6g2xowq",<br/>  "ap-chuncheon-1": "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaaa3cuoai5lfap4e2w3l5jk5262rvafl7dpwlistkkntexiu5h25bq",<br/>  "ap-hyderabad-1": "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaaxxuf3ebmgzy32bzlfjhbyr4vpn3rqtqodi5c24kwjojosea6zzbq",<br/>  "ap-melbourne-1": "ocid1.image.oc1.ap-melbourne-1.aaaaaaaameaiob3abo7nzzg4hb2kmwi5ihqmkpbwt2hax65szewv52rt3z6a",<br/>  "ap-mumbai-1": "ocid1.image.oc1.ap-mumbai-1.aaaaaaaacm56ci4xs3fqx7zsrxvedeqplrlp6gxy6lnga4qi62wywssusmkq",<br/>  "ap-osaka-1": "ocid1.image.oc1.ap-osaka-1.aaaaaaaawzfbc5pjimseh6eisfqhfztalzx46h5bhntvxomckmulk7hqtyoa",<br/>  "ap-seoul-1": "ocid1.image.oc1.ap-seoul-1.aaaaaaaay3tcv6ttdutmyu32prvdidg5lojd2lzhue4eqnycor5oofiodeyq",<br/>  "ap-singapore-1": "ocid1.image.oc1.ap-singapore-1.aaaaaaaamhhpqoyiobauojy3m2huj6tusesizrggbpek2wo4tksiwwv43ihq",<br/>  "ap-sydney-1": "ocid1.image.oc1.ap-sydney-1.aaaaaaaahbktlxr6owykyfvduw5b24giid5stnncevl2nif6pdcgtscd5h5q",<br/>  "ap-tokyo-1": "ocid1.image.oc1.ap-tokyo-1.aaaaaaaaj7gohm3adsdbhhn7emx7bd6jny7dj5mipwnq62ub6eeryjgr7gnq",<br/>  "ca-montreal-1": "ocid1.image.oc1.ca-montreal-1.aaaaaaaacezsnh42klz6sd5hlqsrlmypeqk4hxo3xphii4qa2l2gw2lkkm7a",<br/>  "ca-toronto-1": "ocid1.image.oc1.ca-toronto-1.aaaaaaaaypprlzb5aftk77ltpwspqtvdk2bbtsxiknqycci2kxznfcuihfsa",<br/>  "eu-amsterdam-1": "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaaadazle32svd6dhz4ano5iqxh22bqoy3c6gaodvhg7x7iaq23yxnq",<br/>  "eu-frankfurt-1": "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaajzudgoto32j5q245xjkm2p7nj6rrza2bb5yyqjgm56k4ib2to6sq",<br/>  "eu-madrid-1": "ocid1.image.oc1.eu-madrid-1.aaaaaaaawo47bihidpyebw2zlaptpbmeqx7zsww6bllr4uybttrblcmtmvjq",<br/>  "eu-marseille-1": "ocid1.image.oc1.eu-marseille-1.aaaaaaaa3334ijm2zwbgmkqrrbkh2ecyekudopjkcndrrw5nhbeoyk66kiqa",<br/>  "eu-milan-1": "ocid1.image.oc1.eu-milan-1.aaaaaaaae3hiyvu2hdfblxr4xp2tpvbiow7nvpner6ekvysc5whmzyaqjoqa",<br/>  "eu-paris-1": "ocid1.image.oc1.eu-paris-1.aaaaaaaaeagkmkwv5cl7x2f2ylekvqxlnnlkahuepxmck7yawdkjmg6e5ypq",<br/>  "eu-stockholm-1": "ocid1.image.oc1.eu-stockholm-1.aaaaaaaad5qwbyuemyoa2hrngbb4iydmb5nfcfn3s3jki7qqhlmkomoscv6q",<br/>  "eu-zurich-1": "ocid1.image.oc1.eu-zurich-1.aaaaaaaas6gvo5dqyqpisatcs56my2ldwc4xc57lydfrzfbuutnhjceapdqq",<br/>  "il-jerusalem-1": "ocid1.image.oc1.il-jerusalem-1.aaaaaaaac5e6i6ztlu7ksbn6qujaaqlgpr7xdpcryms3fviq6kpn26p3jhaa",<br/>  "me-abudhabi-1": "ocid1.image.oc1.me-abudhabi-1.aaaaaaaay4xdwt2tzpsqkifdxciuvbvfqwdij2btal7w2gucdguux6vs2iia",<br/>  "me-dubai-1": "ocid1.image.oc1.me-dubai-1.aaaaaaaalu3waogupaq2b2kvi4ny6uxuvjdbdfvgchpk7toinrn7ei6l7toq",<br/>  "me-jeddah-1": "ocid1.image.oc1.me-jeddah-1.aaaaaaaarqfbmwhhapsjv6ncotol2haolzsjg4bkqxngn7cjtdshohee575a",<br/>  "mx-monterrey-1": "ocid1.image.oc1.mx-monterrey-1.aaaaaaaayjefqnzikropxrizlxkdqlu4e4n7mallxolsur2ua2szyoczicza",<br/>  "mx-queretaro-1": "ocid1.image.oc1.mx-queretaro-1.aaaaaaaalob3n6p7hb2c7cabvax6cmzzcrxxl2cexakvytmhfi4vopusjwyq",<br/>  "sa-bogota-1": "ocid1.image.oc1.sa-bogota-1.aaaaaaaac5aytlzu6lk5s6n7frapmvg5xgkpdmc7fci6b56urie54ea46paa",<br/>  "sa-santiago-1": "ocid1.image.oc1.sa-santiago-1.aaaaaaaaeyf2gv5wo5mzsijd3zparivuzwexxaovx3fes3b4am6qn4vjkwrq",<br/>  "sa-saopaulo-1": "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaayiprqwic72dwa6teukf4uyd2vqntqvm4cddvvvjcttsn7zn6jsza",<br/>  "sa-valparaiso-1": "ocid1.image.oc1.sa-valparaiso-1.aaaaaaaau4tjiejqqzfdbelzskgjvbkuc4n3rmwwylzuk3oon3l32ee5ydja",<br/>  "sa-vinhedo-1": "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaahqhs7fl5b2eoarmbv2hibeum4qp6xf7bpuvndsxbwxow2g66xxka",<br/>  "uk-cardiff-1": "ocid1.image.oc1.uk-cardiff-1.aaaaaaaa3tw6w7xa3crrtumyidagfy5sfffm5ulf5wk4n4enq56cfgv3r7pq",<br/>  "uk-london-1": "ocid1.image.oc1.uk-london-1.aaaaaaaahfrghsffkvpikumb7v42bsxlk23medjry234dcspckdnbifbsocq",<br/>  "us-ashburn-1": "ocid1.image.oc1.iad.aaaaaaaaowocjhlbitbc5la6hvimvhi7iseebfzj2honlkyjgqdpuy5syxea",<br/>  "us-chicago-1": "ocid1.image.oc1.us-chicago-1.aaaaaaaa7kpyzoekvmsyvvwutgbnjv2cb4heft7fotyaplsuacdidgxnodwa",<br/>  "us-phoenix-1": "ocid1.image.oc1.phx.aaaaaaaasw7zpqcko4iqizjsnco6e4md6sxmiimdaedzzbb2appwvqn4uyma",<br/>  "us-sanjose-1": "ocid1.image.oc1.us-sanjose-1.aaaaaaaakvkyx6huyxk7vikyswxdcpxt74ix3nwgsbozoxikyoawetjyq7ta"<br/>}</pre> | no |
| <a name="input_instance_shape"></a> [instance\_shape](#input\_instance\_shape) | The OCI compute shape (VM.Standard.A1.Flex for Free Tier ARM instances) | `string` | `"VM.Standard.A1.Flex"` | no |
| <a name="input_instance_shape_boot_volume_size_gb"></a> [instance\_shape\_boot\_volume\_size\_gb](#input\_instance\_shape\_boot\_volume\_size\_gb) | The size of the boot volume in GBs | `number` | `50` | no |
| <a name="input_instance_shape_config_memory_gb"></a> [instance\_shape\_config\_memory\_gb](#input\_instance\_shape\_config\_memory\_gb) | The amount of memory in GBs for the instance | `number` | `24` | no |
| <a name="input_instance_shape_config_ocpus"></a> [instance\_shape\_config\_ocpus](#input\_instance\_shape\_config\_ocpus) | The number of OCPUs for the instance | `number` | `4` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The OCID of the KMS key to use for volume encryption. If null, volumes will not be encrypted with customer-managed keys. | `string` | `null` | no |
| <a name="input_oracle_api_key_fingerprint"></a> [oracle\_api\_key\_fingerprint](#input\_oracle\_api\_key\_fingerprint) | The fingerprint of the OCI API public key | `string` | n/a | yes |
| <a name="input_oracle_api_private_key_path"></a> [oracle\_api\_private\_key\_path](#input\_oracle\_api\_private\_key\_path) | The path to the OCI API private key file | `string` | `"~/.oci/oci_api_key.pem"` | no |
| <a name="input_region"></a> [region](#input\_region) | The OCI region to deploy resources | `string` | `"eu-milan-1"` | no |
| <a name="input_runtipi_adguard_ip"></a> [runtipi\_adguard\_ip](#input\_runtipi\_adguard\_ip) | The static IP for AdGuard. Must be within runtipi\_main\_network\_subnet and different from reverse proxy IP | `string` | `"172.18.0.253"` | no |
| <a name="input_runtipi_main_network_subnet"></a> [runtipi\_main\_network\_subnet](#input\_runtipi\_main\_network\_subnet) | The Docker network subnet for RunTipi containers | `string` | `"172.18.0.0/16"` | no |
| <a name="input_runtipi_reverse_proxy_ip"></a> [runtipi\_reverse\_proxy\_ip](#input\_runtipi\_reverse\_proxy\_ip) | The static IP for RunTipi reverse proxy (Traefik). Must be within runtipi\_main\_network\_subnet | `string` | `"172.18.0.254"` | no |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | The public key to use for SSH access | `string` | n/a | yes |
| <a name="input_ssh_source_cidr"></a> [ssh\_source\_cidr](#input\_ssh\_source\_cidr) | Source CIDR allowed for SSH access (default: 0.0.0.0/0 — all IPs) | `string` | `"0.0.0.0/0"` | no |
| <a name="input_subnet_cidr_block"></a> [subnet\_cidr\_block](#input\_subnet\_cidr\_block) | The CIDR block for the subnet (must be within vcn\_cidr\_block; OCI will reject it at apply time otherwise) | `string` | `"10.1.0.0/24"` | no |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | The OCID of the tenancy | `string` | n/a | yes |
| <a name="input_user_ocid"></a> [user\_ocid](#input\_user\_ocid) | The OCID of the user to use for authentication | `string` | n/a | yes |
| <a name="input_vcn_cidr_block"></a> [vcn\_cidr\_block](#input\_vcn\_cidr\_block) | The CIDR block for the VCN | `string` | `"10.1.0.0/16"` | no |
| <a name="input_wireguard_client_configuration"></a> [wireguard\_client\_configuration](#input\_wireguard\_client\_configuration) | WireGuard client configuration (wg0.conf content). If provided, WireGuard will be installed and configured automatically | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_domain"></a> [availability\_domain](#output\_availability\_domain) | The availability domain where resources are deployed |
| <a name="output_docker_volume_id"></a> [docker\_volume\_id](#output\_docker\_volume\_id) | The OCID of the Docker volume |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | The OCID of the instance |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | The private IP of the instance |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | The public IP of the instance |
| <a name="output_security_list_id"></a> [security\_list\_id](#output\_security\_list\_id) | The OCID of the security list |
| <a name="output_ssh_connection"></a> [ssh\_connection](#output\_ssh\_connection) | SSH command to connect to the instance |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | The OCID of the subnet |
| <a name="output_vcn_id"></a> [vcn\_id](#output\_vcn\_id) | The OCID of the VCN |
<!-- END_TF_DOCS -->
