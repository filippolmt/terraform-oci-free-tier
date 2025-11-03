# Terraform OCI Free Tier

This repository provides Terraform configurations for deploying resources in the Oracle Cloud Infrastructure (OCI) Free Tier.

## Table of Contents

- [Terraform OCI Free Tier](#terraform-oci-free-tier)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
  - [Usage](#usage)
  - [Files](#files)
  - [RunTipi Configuration](#runtipi-configuration)
  - [License](#license)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) or [OpenTofu](https://opentofu.org/docs/intro/install/) installed on your local machine.
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

- `main.tf`: Main Terraform configuration file.
- `outputs.tf`: Defines the outputs of the Terraform configuration.
- `variables.tf`: Defines the variables used in the Terraform configuration.
- `versions.tf`: Specifies the required Terraform version and provider versions.
- `terraform.tfvars.template`: Template for user-specific variables.
- `.github/workflows/`: Contains GitHub Actions workflows for CI/CD.
    - `documentation.yml`: Workflow for generating documentation.
    - `tfsec.yml`: Workflow for running TFsec security scans.
- `scripts/startup.sh`: Script for initial setup and configuration. By default, this script installs RunTipi unless the `install_runtipi` variable is set to `false`.

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
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | 7.24.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | 7.24.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_core_default_route_table.default_route_table](https://registry.terraform.io/providers/oracle/oci/7.24.0/docs/resources/core_default_route_table) | resource |
| [oci_core_instance.instance](https://registry.terraform.io/providers/oracle/oci/7.24.0/docs/resources/core_instance) | resource |
| [oci_core_internet_gateway.internet_gateway](https://registry.terraform.io/providers/oracle/oci/7.24.0/docs/resources/core_internet_gateway) | resource |
| [oci_core_public_ip.public_ip](https://registry.terraform.io/providers/oracle/oci/7.24.0/docs/resources/core_public_ip) | resource |
| [oci_core_security_list.security_list](https://registry.terraform.io/providers/oracle/oci/7.24.0/docs/resources/core_security_list) | resource |
| [oci_core_subnet.subnet](https://registry.terraform.io/providers/oracle/oci/7.24.0/docs/resources/core_subnet) | resource |
| [oci_core_vcn.vcn](https://registry.terraform.io/providers/oracle/oci/7.24.0/docs/resources/core_vcn) | resource |
| [oci_core_volume.docker_volume](https://registry.terraform.io/providers/oracle/oci/7.24.0/docs/resources/core_volume) | resource |
| [oci_core_volume_attachment.docker_volume_attachment](https://registry.terraform.io/providers/oracle/oci/7.24.0/docs/resources/core_volume_attachment) | resource |
| [oci_core_volume_backup_policy.docker_volume_backup_policy](https://registry.terraform.io/providers/oracle/oci/7.24.0/docs/resources/core_volume_backup_policy) | resource |
| [oci_core_volume_backup_policy_assignment.docker_volume_backup_policy_assignment](https://registry.terraform.io/providers/oracle/oci/7.24.0/docs/resources/core_volume_backup_policy_assignment) | resource |
| [oci_core_private_ips.instance_private_ip](https://registry.terraform.io/providers/oracle/oci/7.24.0/docs/data-sources/core_private_ips) | data source |
| [oci_core_vnic.instance_vnic](https://registry.terraform.io/providers/oracle/oci/7.24.0/docs/data-sources/core_vnic) | data source |
| [oci_core_vnic_attachments.instance_vnics](https://registry.terraform.io/providers/oracle/oci/7.24.0/docs/data-sources/core_vnic_attachments) | data source |
| [oci_identity_availability_domain.ad](https://registry.terraform.io/providers/oracle/oci/7.24.0/docs/data-sources/identity_availability_domain) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_ssh_public_key"></a> [additional\_ssh\_public\_key](#input\_additional\_ssh\_public\_key) | Additional public key to use for SSH access example: <<EOF > /home/ubuntu/.ssh/authorized\_keys ssh-rsa AAAAB3NzaC1yc2EAA EOF | `string` | `""` | no |
| <a name="input_availability_domain_number"></a> [availability\_domain\_number](#input\_availability\_domain\_number) | The availability domain number | `number` | `1` | no |
| <a name="input_compartment_ocid"></a> [compartment\_ocid](#input\_compartment\_ocid) | The OCID of the compartment | `string` | n/a | yes |
| <a name="input_docker_volume_size_gb"></a> [docker\_volume\_size\_gb](#input\_docker\_volume\_size\_gb) | The size of the docker volume in GBs | `string` | `"150"` | no |
| <a name="input_fault_domain"></a> [fault\_domain](#input\_fault\_domain) | The fault domain to deploy to | `string` | `"FAULT-DOMAIN-2"` | no |
| <a name="input_install_runtipi"></a> [install\_runtipi](#input\_install\_runtipi) | Install Homeserver Runtipi refs: https://runtipi.io/ | `bool` | `true` | no |
| <a name="input_instance_display_name"></a> [instance\_display\_name](#input\_instance\_display\_name) | The display name of the instance | `string` | `"DockerHost"` | no |
| <a name="input_instance_image_ocids_by_region"></a> [instance\_image\_ocids\_by\_region](#input\_instance\_image\_ocids\_by\_region) | The OCID of the image to use for the instance | `map(string)` | <pre>{<br/>  "af-johannesburg-1": "ocid1.image.oc1.af-johannesburg-1.aaaaaaaak5nlhyhiwafbxjhlreejewizjs7nhod257vja2eh6vkernjckbja",<br/>  "ap-chuncheon-1": "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaabectst4fkxq5avpaf4dstmemodqmdo5txhs3632etb34vuer6ajq",<br/>  "ap-hyderabad-1": "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaajrplcfdj6tfe7hsnyxvd2mi6rny2qqxnvd33xcaz236yt2vwd6ga",<br/>  "ap-melbourne-1": "ocid1.image.oc1.ap-melbourne-1.aaaaaaaarbrgko6mxlnkc7ygr6pvm57mhldu375o44g7r5ph5khg44zwssoq",<br/>  "ap-mumbai-1": "ocid1.image.oc1.ap-mumbai-1.aaaaaaaa3ijqnvqa6hwhl3xu2eiqydzx77ukfu6rafhxfhqhemwugvci6gxa",<br/>  "ap-osaka-1": "ocid1.image.oc1.ap-osaka-1.aaaaaaaa32nht45vu6d4xf3dlqydt2k2zghlds3fzdm5oidnonjgrhuon6fa",<br/>  "ap-seoul-1": "ocid1.image.oc1.ap-seoul-1.aaaaaaaacmscv6qm77y3zqudoyrlt4552gubvrfoui7efp64kuqgeir4s3oq",<br/>  "ap-singapore-1": "ocid1.image.oc1.ap-singapore-1.aaaaaaaas6w45vtj7baofaex5q3sukv2idpn2bchseh3zvkg4mzygmeafu2q",<br/>  "ap-sydney-1": "ocid1.image.oc1.ap-sydney-1.aaaaaaaae2z2lh5w2oc6hw67tgl3azrlhcfhipjqtxpt264gtdlyaxc6vaaq",<br/>  "ap-tokyo-1": "ocid1.image.oc1.ap-tokyo-1.aaaaaaaalryqosses53brtxfexpfipf5ynu6pkyjr3ge4qfp6o4fijw5ufzq",<br/>  "ca-montreal-1": "ocid1.image.oc1.ca-montreal-1.aaaaaaaaolt2nqgxdh7mhvyzikp7gzv5m6tny6qaogct3vt47qtwzjaactdq",<br/>  "ca-toronto-1": "ocid1.image.oc1.ca-toronto-1.aaaaaaaabt3juibcfbfeuebkpvnpewvegbp73gzcyomcjatxgj47sj37yxpq",<br/>  "eu-amsterdam-1": "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaae7inuayr2d33djwyagj4vp7nhd6tkzdql7bs4shiypeiimhaiusq",<br/>  "eu-frankfurt-1": "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaafb2sye3yjqkh3ejoeindkf2jgbgo2cciffs6sbwnpbgvclz6q5zq",<br/>  "eu-madrid-1": "ocid1.image.oc1.eu-madrid-1.aaaaaaaacxmqpivwimu5jo6tu74du272itlj66zmo5i5yhsuh6cfurflyuaa",<br/>  "eu-marseille-1": "ocid1.image.oc1.eu-marseille-1.aaaaaaaalqlrae7xkknyorkhptgxgofu3gxpr7d3umm4stjwdm7p6ae4ygma",<br/>  "eu-milan-1": "ocid1.image.oc1.eu-milan-1.aaaaaaaaq4bgs3zvqpowagemvdn273poop5vlwdls2isccsrhphekmhe6mma",<br/>  "eu-paris-1": "ocid1.image.oc1.eu-paris-1.aaaaaaaados7dqzmqbrsgtveuc5sgizkceosa652dgwh5rqcigobci3gyxxa",<br/>  "eu-stockholm-1": "ocid1.image.oc1.eu-stockholm-1.aaaaaaaaptkd6ru6chhcbdvuucqhvo57365zsr2gneiujccq3ku7fet3axoa",<br/>  "eu-zurich-1": "ocid1.image.oc1.eu-zurich-1.aaaaaaaalujwiioxws4mnipycn5vidqecrrua4kji43a4upmmrsknhxsuqna",<br/>  "il-jerusalem-1": "ocid1.image.oc1.il-jerusalem-1.aaaaaaaah4pjacbzz4h43yrof6nu5jardm32o4qtf4okuvrxagrihesu5vuq",<br/>  "me-abudhabi-1": "ocid1.image.oc1.me-abudhabi-1.aaaaaaaapxqovvd6m2nkm2nrgzy7wsj5qjbb2j4yiozmoyw7tv3ol7c5kykq",<br/>  "me-dubai-1": "ocid1.image.oc1.me-dubai-1.aaaaaaaa5tu7ioxcwtlolpbirzlusintftwniris5drsimxod3yow3uv2vxa",<br/>  "me-jeddah-1": "ocid1.image.oc1.me-jeddah-1.aaaaaaaaevyhfuwgnfykdjrxi2myvahwpeysms3p2p66l326mx6bznfccyaa",<br/>  "mx-monterrey-1": "ocid1.image.oc1.mx-monterrey-1.aaaaaaaaoc2qwggifssdczjafywxq5jke4qfhxylwhgdytzhimu2dvcyc3ua",<br/>  "mx-queretaro-1": "ocid1.image.oc1.mx-queretaro-1.aaaaaaaaoea6l3ycev6sqelqr2ubsstaqmbh4zd6gd4wndvjwlfid5xm3eqa",<br/>  "sa-bogota-1": "ocid1.image.oc1.sa-bogota-1.aaaaaaaatqyy2dfmajvult6mqtkl3bb4timvj6p2l3wvjo3rx25ycby3tyga",<br/>  "sa-santiago-1": "ocid1.image.oc1.sa-santiago-1.aaaaaaaajhisswibdmpgchjvplqrsj4j52qysejm7gf3ypzism57ouyztzwa",<br/>  "sa-saopaulo-1": "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaaogxf4iaptvdbpdsnw6yhq75ielbqb3iszryvtzekhce2dhl4okia",<br/>  "sa-valparaiso-1": "ocid1.image.oc1.sa-valparaiso-1.aaaaaaaaibiuvwkfiv4mdx6ugrjyxt7pwxxf5fsijuvnpwe4r7x2wz23vxha",<br/>  "sa-vinhedo-1": "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaazhjq6mqh32iy5suhgrsotkwyfe7ngxkz3sjc7ykwjydyn4v7eljq",<br/>  "uk-cardiff-1": "ocid1.image.oc1.uk-cardiff-1.aaaaaaaanydredih3rrjj2qkyt7zhdczfsuyrtdwdzbfaoy67mxuvyaz4g3q",<br/>  "uk-london-1": "ocid1.image.oc1.uk-london-1.aaaaaaaaiqj4r4akxsvm25b5ky2fw6jd2bytcktj7ub3ar7muxrbgdbyo2wa",<br/>  "us-ashburn-1": "ocid1.image.oc1.iad.aaaaaaaaoxcb6yp3brpepe726ar3bsadhbs3mqrn6cyaeq2dneo75opgfija",<br/>  "us-chicago-1": "ocid1.image.oc1.us-chicago-1.aaaaaaaa3oczz5wayypofsav2lnjfsw3iwh47t3vijjn6jx5ptejfgbatmiq",<br/>  "us-phoenix-1": "ocid1.image.oc1.phx.aaaaaaaarwjbs4jfdqbwsf24tqxv2c7ca5q4zwswesglupowndgnqmkio56q",<br/>  "us-sanjose-1": "ocid1.image.oc1.us-sanjose-1.aaaaaaaaojmqa2wacgixftl4xvkvvjkyx455cnetuigp4qgord5gokknwlaa"<br/>}</pre> | no |
| <a name="input_instance_shape"></a> [instance\_shape](#input\_instance\_shape) | The shape of the instance | `string` | `"VM.Standard.A1.Flex"` | no |
| <a name="input_instance_shape_boot_volume_size_gb"></a> [instance\_shape\_boot\_volume\_size\_gb](#input\_instance\_shape\_boot\_volume\_size\_gb) | The size of the boot volume in GBs | `string` | `"50"` | no |
| <a name="input_instance_shape_config_memory_gb"></a> [instance\_shape\_config\_memory\_gb](#input\_instance\_shape\_config\_memory\_gb) | The amount of memory in GBs for the instance | `string` | `"24"` | no |
| <a name="input_instance_shape_config_ocpus"></a> [instance\_shape\_config\_ocpus](#input\_instance\_shape\_config\_ocpus) | The number of OCPUs for the instance | `string` | `"4"` | no |
| <a name="input_oracle_api_key_fingerprint"></a> [oracle\_api\_key\_fingerprint](#input\_oracle\_api\_key\_fingerprint) | The fingerprint of the public key | `string` | n/a | yes |
| <a name="input_oracle_api_private_key_path"></a> [oracle\_api\_private\_key\_path](#input\_oracle\_api\_private\_key\_path) | The path to the private key | `string` | `"~/.oci/oci_api_key.pem"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to deploy to | `string` | `"eu-milan-1"` | no |
| <a name="input_runtipi_adguard_ip"></a> [runtipi\_adguard\_ip](#input\_runtipi\_adguard\_ip) | The IP of the AdGuard for Runtipi, WARNING: this IP should be in the subnet of the main network and different from the reverse proxy IP | `string` | `"172.18.0.253"` | no |
| <a name="input_runtipi_main_network_subnet"></a> [runtipi\_main\_network\_subnet](#input\_runtipi\_main\_network\_subnet) | The subnet of the main network for Runtipi | `string` | `"172.18.0.0/16"` | no |
| <a name="input_runtipi_reverse_proxy_ip"></a> [runtipi\_reverse\_proxy\_ip](#input\_runtipi\_reverse\_proxy\_ip) | The IP of the reverse proxy for Runtipi, WARNING: this IP should be in the subnet of the main network | `string` | `"172.18.0.254"` | no |
| <a name="input_security_list_rules"></a> [security\_list\_rules](#input\_security\_list\_rules) | The security list rules | <pre>list(object({<br/>    protocol  = string<br/>    source    = string<br/>    stateless = bool<br/>    tcp_options = object({<br/>      source_port_range = object({<br/>        min = number<br/>        max = number<br/>      })<br/>      min = number<br/>      max = number<br/>    })<br/>    udp_options = object({<br/>      source_port_range = object({<br/>        min = number<br/>        max = number<br/>      })<br/>      min = number<br/>      max = number<br/>    })<br/>    icmp_options = object({<br/>      type = number<br/>      code = number<br/>    })<br/>  }))</pre> | <pre>[<br/>  {<br/>    "icmp_options": null,<br/>    "protocol": "6",<br/>    "source": "0.0.0.0/0",<br/>    "stateless": false,<br/>    "tcp_options": {<br/>      "max": 22,<br/>      "min": 22,<br/>      "source_port_range": {<br/>        "max": 65535,<br/>        "min": 1<br/>      }<br/>    },<br/>    "udp_options": null<br/>  },<br/>  {<br/>    "icmp_options": null,<br/>    "protocol": "17",<br/>    "source": "0.0.0.0/0",<br/>    "stateless": false,<br/>    "tcp_options": null,<br/>    "udp_options": {<br/>      "max": 51820,<br/>      "min": 51820,<br/>      "source_port_range": {<br/>        "max": 65535,<br/>        "min": 1<br/>      }<br/>    }<br/>  },<br/>  {<br/>    "icmp_options": {<br/>      "code": 4,<br/>      "type": 3<br/>    },<br/>    "protocol": "1",<br/>    "source": "0.0.0.0/0",<br/>    "stateless": false,<br/>    "tcp_options": null,<br/>    "udp_options": null<br/>  }<br/>]</pre> | no |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | The public key to use for SSH access | `string` | n/a | yes |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | The OCID of the tenancy | `string` | n/a | yes |
| <a name="input_user_ocid"></a> [user\_ocid](#input\_user\_ocid) | The OCID of the user to use for authentication | `string` | n/a | yes |
| <a name="input_vcn_cidr_block"></a> [vcn\_cidr\_block](#input\_vcn\_cidr\_block) | The CIDR block for the VCN | `string` | `"10.1.0.0/16"` | no |
| <a name="input_wireguard_client_configuration"></a> [wireguard\_client\_configuration](#input\_wireguard\_client\_configuration) | Adding a valid configuration for a WireGuard client will automatically install and configure it on the virtual machine. Example:<<EOF<br/><br/>[Interface]<br/>PrivateKey = aaaaaaaaaaaaaaa<br/>Address = 1.2.3.4/24<br/>DNS = 5.6.7.8<br/>DNS = 9.1.1.1<br/><br/>[Peer]<br/>PublicKey = bbbbbbbbbbbbbbbbbb<br/>PresharedKey = ccccccccccccccc<br/>AllowedIPs = 0.0.0.0/24<br/>Endpoint = dddddddddddddd<br/>PersistentKeepalive = 25<br/>EOF | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | The OCID of the instance |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | The private IP of the instance |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | The public IP of the instance |
<!-- END_TF_DOCS -->
