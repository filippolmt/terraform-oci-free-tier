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
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | 6.8.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | 6.8.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_core_default_route_table.default_route_table](https://registry.terraform.io/providers/oracle/oci/6.8.0/docs/resources/core_default_route_table) | resource |
| [oci_core_instance.instance](https://registry.terraform.io/providers/oracle/oci/6.8.0/docs/resources/core_instance) | resource |
| [oci_core_internet_gateway.internet_gateway](https://registry.terraform.io/providers/oracle/oci/6.8.0/docs/resources/core_internet_gateway) | resource |
| [oci_core_public_ip.public_ip](https://registry.terraform.io/providers/oracle/oci/6.8.0/docs/resources/core_public_ip) | resource |
| [oci_core_security_list.security_list](https://registry.terraform.io/providers/oracle/oci/6.8.0/docs/resources/core_security_list) | resource |
| [oci_core_subnet.subnet](https://registry.terraform.io/providers/oracle/oci/6.8.0/docs/resources/core_subnet) | resource |
| [oci_core_vcn.vcn](https://registry.terraform.io/providers/oracle/oci/6.8.0/docs/resources/core_vcn) | resource |
| [oci_core_volume.docker_volume](https://registry.terraform.io/providers/oracle/oci/6.8.0/docs/resources/core_volume) | resource |
| [oci_core_volume_attachment.docker_volume_attachment](https://registry.terraform.io/providers/oracle/oci/6.8.0/docs/resources/core_volume_attachment) | resource |
| [oci_core_volume_backup_policy.docker_volume_backup_policy](https://registry.terraform.io/providers/oracle/oci/6.8.0/docs/resources/core_volume_backup_policy) | resource |
| [oci_core_volume_backup_policy_assignment.docker_volume_backup_policy_assignment](https://registry.terraform.io/providers/oracle/oci/6.8.0/docs/resources/core_volume_backup_policy_assignment) | resource |
| [oci_core_private_ips.instance_private_ip](https://registry.terraform.io/providers/oracle/oci/6.8.0/docs/data-sources/core_private_ips) | data source |
| [oci_core_vnic.instance_vnic](https://registry.terraform.io/providers/oracle/oci/6.8.0/docs/data-sources/core_vnic) | data source |
| [oci_core_vnic_attachments.instance_vnics](https://registry.terraform.io/providers/oracle/oci/6.8.0/docs/data-sources/core_vnic_attachments) | data source |
| [oci_identity_availability_domain.ad](https://registry.terraform.io/providers/oracle/oci/6.8.0/docs/data-sources/identity_availability_domain) | data source |

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
| <a name="input_instance_image_ocids_by_region"></a> [instance\_image\_ocids\_by\_region](#input\_instance\_image\_ocids\_by\_region) | The OCID of the image to use for the instance | `map(string)` | <pre>{<br>  "af-johannesburg-1": "ocid1.image.oc1.af-johannesburg-1.aaaaaaaa7xnljvdm5kpk4m7zt7spaqyb3qjikwitnzpoebw7ggamy4exzv7a",<br>  "ap-chuncheon-1": "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaaqlcsenyb566zfbppypis3wnpdi5wzgvh6ni4njx6ni3b54h2f46a",<br>  "ap-hyderabad-1": "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaauqklehbg4utigurndarajxvpcrlokn7doqm2ctwplxqsni76wkza",<br>  "ap-melbourne-1": "ocid1.image.oc1.ap-melbourne-1.aaaaaaaaxttpznd6kgln75wmdtalxmh374dc7vryk6ogxy4odv7ah5oh4coa",<br>  "ap-mumbai-1": "ocid1.image.oc1.ap-mumbai-1.aaaaaaaaroeqq2dbas6jtuyszivuul4z2kec2fytvefcx4yn6nmxo2dmgo5a",<br>  "ap-osaka-1": "ocid1.image.oc1.ap-osaka-1.aaaaaaaaslgmmzf52mm5i6fnyeudflxyfpdopd34vezjngyac7r4k4zvsxza",<br>  "ap-seoul-1": "ocid1.image.oc1.ap-seoul-1.aaaaaaaamflo2tuozxfqsfe2ouyldnliqzzbzdnjgixjchsyl36zhz6ued5q",<br>  "ap-singapore-1": "ocid1.image.oc1.ap-singapore-1.aaaaaaaazmtpusw5a62d2ohooa4q3nu3atfpv2hrldek72d3l5ikmghardsq",<br>  "ap-sydney-1": "ocid1.image.oc1.ap-sydney-1.aaaaaaaaerkvnleaqrw5ugplx3k2el5l4pz4rr3exfbjna6ryj5fylocmnma",<br>  "ap-tokyo-1": "ocid1.image.oc1.ap-tokyo-1.aaaaaaaal3hqdorzbtai6mc4bwggjshnog7u4i3xj7jz3v4xtimlmmkqy7ya",<br>  "ca-montreal-1": "ocid1.image.oc1.ca-montreal-1.aaaaaaaaun5fmmveoxeebsdnbs3dp3llsfmf3ol657aa7d3bshvnacxa45eq",<br>  "ca-toronto-1": "ocid1.image.oc1.ca-toronto-1.aaaaaaaauzynkrnddymm7346qpdzemhwqfigibq655ufdywbewpv2n4kmhtq",<br>  "eu-amsterdam-1": "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaal3y4fa7lj6deamse4m4ukkznfeoywb5h6r2y6qdwdqynh2rkx5tq",<br>  "eu-frankfurt-1": "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaylcz7y7w6uolelzd6ruexuqkufkqqgg2nrr6xnvhtukysuolzv4q",<br>  "eu-madrid-1": "ocid1.image.oc1.eu-madrid-1.aaaaaaaaw7wlmoprvzhu5ogyw6zjgdkclgyjidubfh2kzi27ns5tsl4agwcq",<br>  "eu-marseille-1": "ocid1.image.oc1.eu-marseille-1.aaaaaaaao7fvqbnna7orz4xnnpv3vlitdnnmesnz4gk5pzgvfcxgmadmoc4q",<br>  "eu-milan-1": "ocid1.image.oc1.eu-milan-1.aaaaaaaafofjducrv2pz7kj7thpbty2hyv37dtxce3x6cp5rwf2cngi7flva",<br>  "eu-paris-1": "ocid1.image.oc1.eu-paris-1.aaaaaaaaqnoet4akmzpatmorbqio4srukhrd434xh6kg37jp6f4hdlt5mbiq",<br>  "eu-stockholm-1": "ocid1.image.oc1.eu-stockholm-1.aaaaaaaavni5omi3qljq5umzlymbzxdczn3cmvgnfwb4tdfsls6qyehlv43q",<br>  "eu-zurich-1": "ocid1.image.oc1.eu-zurich-1.aaaaaaaaswipxdoxr6pwu2mjk6lff5r4prkmuhufucw5kjaf7446ksx37d7q",<br>  "il-jerusalem-1": "ocid1.image.oc1.il-jerusalem-1.aaaaaaaadzptbcjtrf7tx5sejgc7onb47u5ckrvakivyk6d2lueukm4uumsq",<br>  "me-abudhabi-1": "ocid1.image.oc1.me-abudhabi-1.aaaaaaaaocrezb6kjxfj6ksp6xqpq2rvdxujxfk7sjrvcyjtavjs4eyzy4na",<br>  "me-dubai-1": "ocid1.image.oc1.me-dubai-1.aaaaaaaaiiykp2iuznxgzrcrm2ln6o5nhfpfwuzlmwkvnmwgrzv747wfhowq",<br>  "me-jeddah-1": "ocid1.image.oc1.me-jeddah-1.aaaaaaaaaicrqlmq7qfk7gh2dnw5ett3z5qqwzof7kzt7mwij6fmwzqhi22a",<br>  "mx-monterrey-1": "ocid1.image.oc1.mx-monterrey-1.aaaaaaaaxqkk6akz7d2d356dk742kxq53kkfemewtlun6gj5jceeaddu2tkq",<br>  "mx-queretaro-1": "ocid1.image.oc1.mx-queretaro-1.aaaaaaaakty7iicnprrzzdv7mr5onnbigbq6i4vaudobx3x6ya34uryrrmqa",<br>  "sa-bogota-1": "ocid1.image.oc1.sa-bogota-1.aaaaaaaagpfqtybbtm5pikjd6qivrjd6d7p7y556rystirdayle6n3nxdzoa",<br>  "sa-santiago-1": "ocid1.image.oc1.sa-santiago-1.aaaaaaaan4ex5fu662bmizpkpu3vxalty7j6waowogwmebiyijhiomin2yja",<br>  "sa-saopaulo-1": "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaaeor33zqzryd3smqgyg2arr4whsuobbtlwzxazovoto5vjnckaacq",<br>  "sa-valparaiso-1": "ocid1.image.oc1.sa-valparaiso-1.aaaaaaaafj5y2dbizrqlr44ytyxukkejp3heuork3whgdec7h5sw3ckw7whq",<br>  "sa-vinhedo-1": "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaahwildebomq43h7xaufnbkgx6n2qvn5kihndcvkzmjy3vhwaqx5ka",<br>  "uk-cardiff-1": "ocid1.image.oc1.uk-cardiff-1.aaaaaaaak55bg7dku2z3smbb3nczyj6jwmhlashfazcc3iemqmbwyjthic5a",<br>  "uk-london-1": "ocid1.image.oc1.uk-london-1.aaaaaaaantzj7ujtr5wcojxtgc76oveoq5xcz7egczd56x67wivib3hfak3q",<br>  "us-ashburn-1": "ocid1.image.oc1.iad.aaaaaaaai42i6avvfxqawj3bjl5uzhlyq5lqkqhbeg4lpo5corvwqgnvrloq",<br>  "us-chicago-1": "ocid1.image.oc1.us-chicago-1.aaaaaaaazcw4u4fboyq5t33t7dj3jbwqvgy4jbkgxfmtxs2xxdnczshdhusa",<br>  "us-phoenix-1": "ocid1.image.oc1.phx.aaaaaaaativnqm7keyzvvmetzp5cxlavfk5xyylt6w2epbjjjwmkv6xijnbq",<br>  "us-sanjose-1": "ocid1.image.oc1.us-sanjose-1.aaaaaaaaouu2iwsejzxx3mqrczvmcx3az4jcnztjoysn3whf2oxamob22jqq"<br>}</pre> | no |
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
| <a name="input_security_list_rules"></a> [security\_list\_rules](#input\_security\_list\_rules) | The security list rules | <pre>list(object({<br>    protocol  = string<br>    source    = string<br>    stateless = bool<br>    tcp_options = object({<br>      source_port_range = object({<br>        min = number<br>        max = number<br>      })<br>      min = number<br>      max = number<br>    })<br>    udp_options = object({<br>      source_port_range = object({<br>        min = number<br>        max = number<br>      })<br>      min = number<br>      max = number<br>    })<br>    icmp_options = object({<br>      type = number<br>      code = number<br>    })<br>  }))</pre> | <pre>[<br>  {<br>    "icmp_options": null,<br>    "protocol": "6",<br>    "source": "0.0.0.0/0",<br>    "stateless": false,<br>    "tcp_options": {<br>      "max": 22,<br>      "min": 22,<br>      "source_port_range": {<br>        "max": 65535,<br>        "min": 1<br>      }<br>    },<br>    "udp_options": null<br>  },<br>  {<br>    "icmp_options": null,<br>    "protocol": "17",<br>    "source": "0.0.0.0/0",<br>    "stateless": false,<br>    "tcp_options": null,<br>    "udp_options": {<br>      "max": 51820,<br>      "min": 51820,<br>      "source_port_range": {<br>        "max": 65535,<br>        "min": 1<br>      }<br>    }<br>  },<br>  {<br>    "icmp_options": {<br>      "code": 4,<br>      "type": 3<br>    },<br>    "protocol": "1",<br>    "source": "0.0.0.0/0",<br>    "stateless": false,<br>    "tcp_options": null,<br>    "udp_options": null<br>  }<br>]</pre> | no |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | The public key to use for SSH access | `string` | n/a | yes |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | The OCID of the tenancy | `string` | n/a | yes |
| <a name="input_user_ocid"></a> [user\_ocid](#input\_user\_ocid) | The OCID of the user to use for authentication | `string` | n/a | yes |
| <a name="input_vcn_cidr_block"></a> [vcn\_cidr\_block](#input\_vcn\_cidr\_block) | The CIDR block for the VCN | `string` | `"10.1.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_"></a> [](#output\_) | n/a |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | The OCID of the instance |
<!-- END_TF_DOCS -->
