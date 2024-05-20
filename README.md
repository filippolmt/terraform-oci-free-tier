# Terraform OCI Free Tier

This repository provides Terraform configurations for deploying resources in Oracle Cloud Infrastructure (OCI) Free Tier.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Usage](#usage)
- [Files](#files)
- [License](#license)

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
- Oracle Cloud Infrastructure (OCI) account.
- OCI CLI configured with your credentials.

## Setup

1. **Clone the repository**:
    ```bash
    git clone https://github.com/filippolmt/terraform-oci-free-tier.git
    cd terraform-oci-free-tier
    ```

2. **Configure your variables**:
    Copy the `terraform.tfvars.template` to `terraform.tfvars` and fill in the required variables.
    ```bash
    cp terraform.tfvars.template terraform.tfvars
    ```

3. **Initialize Terraform**:
    ```bash
    terraform init
    ```

## Usage

1. **Plan the deployment**:
    ```bash
    terraform plan
    ```

2. **Apply the deployment**:
    ```bash
    terraform apply
    ```

3. **Destroy the deployment**:
    ```bash
    terraform destroy
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
- `scripts/startup.sh`: Script for initial setup and configuration.

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | 5.42.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | 5.42.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_core_default_route_table.default_route_table](https://registry.terraform.io/providers/oracle/oci/5.42.0/docs/resources/core_default_route_table) | resource |
| [oci_core_instance.instance](https://registry.terraform.io/providers/oracle/oci/5.42.0/docs/resources/core_instance) | resource |
| [oci_core_internet_gateway.internet_gateway](https://registry.terraform.io/providers/oracle/oci/5.42.0/docs/resources/core_internet_gateway) | resource |
| [oci_core_public_ip.public_ip](https://registry.terraform.io/providers/oracle/oci/5.42.0/docs/resources/core_public_ip) | resource |
| [oci_core_security_list.security_list](https://registry.terraform.io/providers/oracle/oci/5.42.0/docs/resources/core_security_list) | resource |
| [oci_core_subnet.subnet](https://registry.terraform.io/providers/oracle/oci/5.42.0/docs/resources/core_subnet) | resource |
| [oci_core_vcn.vcn](https://registry.terraform.io/providers/oracle/oci/5.42.0/docs/resources/core_vcn) | resource |
| [oci_core_volume.docker_volume](https://registry.terraform.io/providers/oracle/oci/5.42.0/docs/resources/core_volume) | resource |
| [oci_core_volume_attachment.docker_volume_attachment](https://registry.terraform.io/providers/oracle/oci/5.42.0/docs/resources/core_volume_attachment) | resource |
| [oci_core_volume_backup_policy.docker_volume_backup_policy](https://registry.terraform.io/providers/oracle/oci/5.42.0/docs/resources/core_volume_backup_policy) | resource |
| [oci_core_volume_backup_policy_assignment.docker_volume_backup_policy_assignment](https://registry.terraform.io/providers/oracle/oci/5.42.0/docs/resources/core_volume_backup_policy_assignment) | resource |
| [oci_core_private_ips.instance_private_ip](https://registry.terraform.io/providers/oracle/oci/5.42.0/docs/data-sources/core_private_ips) | data source |
| [oci_core_vnic.instance_vnic](https://registry.terraform.io/providers/oracle/oci/5.42.0/docs/data-sources/core_vnic) | data source |
| [oci_core_vnic_attachments.instance_vnics](https://registry.terraform.io/providers/oracle/oci/5.42.0/docs/data-sources/core_vnic_attachments) | data source |
| [oci_identity_availability_domain.ad](https://registry.terraform.io/providers/oracle/oci/5.42.0/docs/data-sources/identity_availability_domain) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_ssh_public_key"></a> [additional\_ssh\_public\_key](#input\_additional\_ssh\_public\_key) | Additional public key to use for SSH access example: <<EOF > /home/ubuntu/.ssh/authorized\_keys ssh-rsa AAAAB3NzaC1yc2EAA EOF | `string` | `""` | no |
| <a name="input_availability_domain_number"></a> [availability\_domain\_number](#input\_availability\_domain\_number) | The availability domain number | `number` | `1` | no |
| <a name="input_compartment_ocid"></a> [compartment\_ocid](#input\_compartment\_ocid) | The OCID of the compartment | `string` | n/a | yes |
| <a name="input_fault_domain"></a> [fault\_domain](#input\_fault\_domain) | The fault domain to deploy to | `string` | `"FAULT-DOMAIN-2"` | no |
| <a name="input_instance_display_name"></a> [instance\_display\_name](#input\_instance\_display\_name) | The display name of the instance | `string` | `"DockerHost"` | no |
| <a name="input_instance_image_ocid"></a> [instance\_image\_ocid](#input\_instance\_image\_ocid) | The OCID of the image to use for the instance | `map(any)` | <pre>{<br>  "af-johannesburg-1": "ocid1.image.oc1.af-johannesburg-1.aaaaaaaayatt2q3wf65wyaey7soibfye7ilnguxfw2m37xspz2dvnk66avha",<br>  "ap-chuncheon-1": "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaatrfzu3rtfs4clvu3d3lcx3w47dhfwley334h2e4kibgkguof2jbq",<br>  "ap-hyderabad-1": "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaazws25hclevz2gawql32qjxy47t3qm267pki6a7dovu5s5zec5cuq",<br>  "ap-melbourne-1": "ocid1.image.oc1.ap-melbourne-1.aaaaaaaaxdac5qbdmi7kjgurknuoxnw6gopfcf63liqljjh5tt24fpd4j7aa",<br>  "ap-mumbai-1": "ocid1.image.oc1.ap-mumbai-1.aaaaaaaavldnviyso3bjs4ppc6vnvkxhm6cwrd25qxioxvlgfdvuhiolqn3q",<br>  "ap-osaka-1": "ocid1.image.oc1.ap-osaka-1.aaaaaaaanafsjeu6sgbgtcs2unflym5b3ayetwyig3fjav5ld44qkosv4yxq",<br>  "ap-seoul-1": "ocid1.image.oc1.ap-seoul-1.aaaaaaaaaogjhvie4g6lnuaqnedzrnqsyoejaisp2ri4pkifofw3gbfx2fsq",<br>  "ap-singapore-1": "ocid1.image.oc1.ap-singapore-1.aaaaaaaamxlszcgvwvzrknu5b6ajifilcz2g5rdnxzunpqm2tuy5pu5iqf5q",<br>  "ap-sydney-1": "ocid1.image.oc1.ap-sydney-1.aaaaaaaaifa7kduccxfitcylxubkht7cdhl63obna2bkduk6zkvhymbfnxka",<br>  "ap-tokyo-1": "ocid1.image.oc1.ap-tokyo-1.aaaaaaaat7tma2qo5x5ceupmsak7w3qj5pq73ir67b45l7su7y3xltym3eoq",<br>  "ca-montreal-1": "ocid1.image.oc1.ca-montreal-1.aaaaaaaapk2rls5h5v3mtyvtglhq2zglh4a3yyrufz2rdxtspihe6pq4j6va",<br>  "ca-toronto-1": "ocid1.image.oc1.ca-toronto-1.aaaaaaaa24sdg3g3jhzk4xbbzq66lfkw65iuuhsg4rg5vmi5oq6tx2pw2pja",<br>  "eu-amsterdam-1": "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaa2thbdtvsvy477jexghizqta2ncgjpb63yc32cir7ecjo4o2qcf5q",<br>  "eu-frankfurt-1": "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaauowdt3masemltfslfv7rp67e6i4ple7t4u6ygyt5k6ub3vduusiq",<br>  "eu-madrid-1": "ocid1.image.oc1.eu-madrid-1.aaaaaaaaopqz7l22adkrh32xle75d367u5le4cbcalenqssee7kpzek2zera",<br>  "eu-marseille-1": "ocid1.image.oc1.eu-marseille-1.aaaaaaaat6vsgurqc3yqmc6frh3v3fkgos6ftjsdvzbewxz33sd22fnnucca",<br>  "eu-milan-1": "ocid1.image.oc1.eu-milan-1.aaaaaaaayqlb7nqz3gdno4paz3h2qqxkyf4zzfttjnoh4ij2kpcg4467y2ea",<br>  "eu-paris-1": "ocid1.image.oc1.eu-paris-1.aaaaaaaaxvkt7p62m5gwoeffjeocdy26mxdosapdhtld7nxfogc4spooa2sq",<br>  "eu-stockholm-1": "ocid1.image.oc1.eu-stockholm-1.aaaaaaaalifousimc5zr4ypepp6b6bzjqhx5afuulxaqmujuc2voqs5fsn5a",<br>  "eu-zurich-1": "ocid1.image.oc1.eu-zurich-1.aaaaaaaaxluw6jh3jmpyg5dkpsnpg63wzphzac4cdhgfte2fss7g5gcwihca",<br>  "il-jerusalem-1": "ocid1.image.oc1.il-jerusalem-1.aaaaaaaapuniww6o33se3sfty6feri6ktxl6brlwwvsegukjcxoinzwi5wvq",<br>  "me-abudhabi-1": "ocid1.image.oc1.me-abudhabi-1.aaaaaaaa6b2qwjnh7rpzj3meotg55salzwi563hhbmbyks5hf2dezjoyiecq",<br>  "me-dubai-1": "ocid1.image.oc1.me-dubai-1.aaaaaaaag3hbb5cvalx747wg6dplm2cxjc4fq5uux2xbticnc3vjrqzwhxgq",<br>  "me-jeddah-1": "ocid1.image.oc1.me-jeddah-1.aaaaaaaamk2h7ilswb472holpkykgtlyqcsgucr7j7o3k6x2em5pbisywjsq",<br>  "mx-queretaro-1": "ocid1.image.oc1.mx-queretaro-1.aaaaaaaa5ng35ewch32nilgapabou4olvtqxgabpq762p3qx56qy2dwmctaq",<br>  "sa-santiago-1": "ocid1.image.oc1.sa-santiago-1.aaaaaaaal6gxoyh4gfm2vxaua2464ieilwfth77msu7uemfpkadkkt6mjfka",<br>  "sa-saopaulo-1": "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaaqghurigdiwlf726pmgzlzmbqkgo5inn7k7bx5q4lpqhfjsr6apcq",<br>  "sa-vinhedo-1": "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaa3b3p5xmkvam7h2km5irockkgrjl7acnntzbi73u6lcdlmdvwob3a",<br>  "uk-cardiff-1": "ocid1.image.oc1.uk-cardiff-1.aaaaaaaagy2eilwxcrz7y5vyehraeoisdxpg4ub2txsap4q2tn7h3x2uyznq",<br>  "uk-london-1": "ocid1.image.oc1.uk-london-1.aaaaaaaanqwfiejnlcawmwoa2ku73qghuiumgaiffldgfk5ig7xx4tlfcjua",<br>  "us-ashburn-1": "ocid1.image.oc1.iad.aaaaaaaaf4tcgubjzoxwaa4xteropz4zidxitlbjcwogcglzxwtspwiv74ha",<br>  "us-chicago-1": "ocid1.image.oc1.us-chicago-1.aaaaaaaajrmkhokn3hqdlqtevwvcyxh67fknrp5ljo33kp25nci34viblkxq",<br>  "us-phoenix-1": "ocid1.image.oc1.phx.aaaaaaaafpqctvbk7lcxfztmjxhyfd5pyhixs4h23uzjiddjlxfs6eva57xa",<br>  "us-sanjose-1": "ocid1.image.oc1.us-sanjose-1.aaaaaaaa54zxwb6ujfbrycebkkmy4tdc7szox3l76l6un7wfjgln4drzcvda"<br>}</pre> | no |
| <a name="input_instance_shape"></a> [instance\_shape](#input\_instance\_shape) | The shape of the instance | `string` | `"VM.Standard.A1.Flex"` | no |
| <a name="input_instance_shape_boot_volume_size_in_gbs"></a> [instance\_shape\_boot\_volume\_size\_in\_gbs](#input\_instance\_shape\_boot\_volume\_size\_in\_gbs) | The size of the boot volume in GBs | `string` | `"50"` | no |
| <a name="input_instance_shape_config_memory_in_gbs"></a> [instance\_shape\_config\_memory\_in\_gbs](#input\_instance\_shape\_config\_memory\_in\_gbs) | The amount of memory in GBs for the instance | `string` | `"24"` | no |
| <a name="input_instance_shape_config_ocpus"></a> [instance\_shape\_config\_ocpus](#input\_instance\_shape\_config\_ocpus) | The number of OCPUs for the instance | `string` | `"4"` | no |
| <a name="input_instance_shape_docker_volume_size_in_gbs"></a> [instance\_shape\_docker\_volume\_size\_in\_gbs](#input\_instance\_shape\_docker\_volume\_size\_in\_gbs) | The size of the docker volume in GBs | `string` | `"150"` | no |
| <a name="input_oracle_api_key_fingerprint"></a> [oracle\_api\_key\_fingerprint](#input\_oracle\_api\_key\_fingerprint) | The fingerprint of the public key | `string` | n/a | yes |
| <a name="input_oracle_api_private_key_path"></a> [oracle\_api\_private\_key\_path](#input\_oracle\_api\_private\_key\_path) | The path to the private key | `string` | `"~/.oci/oci_api_key.pem"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to deploy to | `string` | `"eu-milan-1"` | no |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | The public key to use for SSH access | `string` | n/a | yes |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | The OCID of the tenancy | `string` | n/a | yes |
| <a name="input_user_ocid"></a> [user\_ocid](#input\_user\_ocid) | The OCID of the user to use for authentication | `string` | n/a | yes |
| <a name="input_vcn_cidr_block"></a> [vcn\_cidr\_block](#input\_vcn\_cidr\_block) | The CIDR block for the VCN | `string` | `"10.1.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | The OCID of the instance |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | The private IP of the instance |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | The public IP of the instance |
<!-- END_TF_DOCS -->
