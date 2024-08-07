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
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | 6.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | 6.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_core_default_route_table.default_route_table](https://registry.terraform.io/providers/oracle/oci/6.6.0/docs/resources/core_default_route_table) | resource |
| [oci_core_instance.instance](https://registry.terraform.io/providers/oracle/oci/6.6.0/docs/resources/core_instance) | resource |
| [oci_core_internet_gateway.internet_gateway](https://registry.terraform.io/providers/oracle/oci/6.6.0/docs/resources/core_internet_gateway) | resource |
| [oci_core_public_ip.public_ip](https://registry.terraform.io/providers/oracle/oci/6.6.0/docs/resources/core_public_ip) | resource |
| [oci_core_security_list.security_list](https://registry.terraform.io/providers/oracle/oci/6.6.0/docs/resources/core_security_list) | resource |
| [oci_core_subnet.subnet](https://registry.terraform.io/providers/oracle/oci/6.6.0/docs/resources/core_subnet) | resource |
| [oci_core_vcn.vcn](https://registry.terraform.io/providers/oracle/oci/6.6.0/docs/resources/core_vcn) | resource |
| [oci_core_volume.docker_volume](https://registry.terraform.io/providers/oracle/oci/6.6.0/docs/resources/core_volume) | resource |
| [oci_core_volume_attachment.docker_volume_attachment](https://registry.terraform.io/providers/oracle/oci/6.6.0/docs/resources/core_volume_attachment) | resource |
| [oci_core_volume_backup_policy.docker_volume_backup_policy](https://registry.terraform.io/providers/oracle/oci/6.6.0/docs/resources/core_volume_backup_policy) | resource |
| [oci_core_volume_backup_policy_assignment.docker_volume_backup_policy_assignment](https://registry.terraform.io/providers/oracle/oci/6.6.0/docs/resources/core_volume_backup_policy_assignment) | resource |
| [oci_core_private_ips.instance_private_ip](https://registry.terraform.io/providers/oracle/oci/6.6.0/docs/data-sources/core_private_ips) | data source |
| [oci_core_vnic.instance_vnic](https://registry.terraform.io/providers/oracle/oci/6.6.0/docs/data-sources/core_vnic) | data source |
| [oci_core_vnic_attachments.instance_vnics](https://registry.terraform.io/providers/oracle/oci/6.6.0/docs/data-sources/core_vnic_attachments) | data source |
| [oci_identity_availability_domain.ad](https://registry.terraform.io/providers/oracle/oci/6.6.0/docs/data-sources/identity_availability_domain) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_ssh_public_key"></a> [additional\_ssh\_public\_key](#input\_additional\_ssh\_public\_key) | Additional public key to use for SSH access example: <<EOF > /home/ubuntu/.ssh/authorized\_keys ssh-rsa AAAAB3NzaC1yc2EAA EOF | `string` | `""` | no |
| <a name="input_availability_domain_number"></a> [availability\_domain\_number](#input\_availability\_domain\_number) | The availability domain number | `number` | `1` | no |
| <a name="input_compartment_ocid"></a> [compartment\_ocid](#input\_compartment\_ocid) | The OCID of the compartment | `string` | n/a | yes |
| <a name="input_fault_domain"></a> [fault\_domain](#input\_fault\_domain) | The fault domain to deploy to | `string` | `"FAULT-DOMAIN-2"` | no |
| <a name="input_instance_display_name"></a> [instance\_display\_name](#input\_instance\_display\_name) | The display name of the instance | `string` | `"DockerHost"` | no |
| <a name="input_instance_image_ocid"></a> [instance\_image\_ocid](#input\_instance\_image\_ocid) | The OCID of the image to use for the instance | `map(any)` | <pre>{<br>  "af-johannesburg-1": "ocid1.image.oc1.af-johannesburg-1.aaaaaaaax333o2ycfo3kez6e2lcw5twqdrkfqrumo6hs3iwhdf27gnnbrx5a",<br>  "ap-chuncheon-1": "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaac45fgllwh5rdl2chkf6xte2yjvqbtlaz7zkhrxs2pcmnlzjbfs5a",<br>  "ap-hyderabad-1": "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaapmowuredsvjoajp2hxhrxxvk4zx6wlpoedptn2vn4jc67i4yzqqq",<br>  "ap-melbourne-1": "ocid1.image.oc1.ap-melbourne-1.aaaaaaaa5ottxpbcv44udrgaivtibl2kclq267g347mhkmxf7sukwe6rlowa",<br>  "ap-mumbai-1": "ocid1.image.oc1.ap-mumbai-1.aaaaaaaaq3emfywi6i7oyi5bzd4o2p4wqw3gq6l4r4wj5qd3azsicfq33iea",<br>  "ap-osaka-1": "ocid1.image.oc1.ap-osaka-1.aaaaaaaalkf7sczol3b2u3e4g365cb44vh2hlwv4y45p4sumobi2nxbrftzq",<br>  "ap-seoul-1": "ocid1.image.oc1.ap-seoul-1.aaaaaaaazsuvtlhqoe67xqgeazq62ykipstgv5ct3i62zfzezxd4tpgcaq2q",<br>  "ap-singapore-1": "ocid1.image.oc1.ap-singapore-1.aaaaaaaapptlp7yb5s6regbd77w2qylyi6d7brnnt3qm5vlmutgiq5jxfb4q",<br>  "ap-sydney-1": "ocid1.image.oc1.ap-sydney-1.aaaaaaaazltimyhsp3vogaujtizcsyauvz3avzyqwdbf7l3jcujj76vzpcna",<br>  "ap-tokyo-1": "ocid1.image.oc1.ap-tokyo-1.aaaaaaaahomava4u6ud4ztzysq3bnn6iktkyfvsthrvs4gjemkacfgpr53yq",<br>  "ca-montreal-1": "ocid1.image.oc1.ca-montreal-1.aaaaaaaa25pkd4hksfm4ryuvj7eendqoo4hel4flpe2lmhlgs3rkw34sam2q",<br>  "ca-toronto-1": "ocid1.image.oc1.ca-toronto-1.aaaaaaaafrhto7vi2lae4i5gki234znbj6i7iiodhychrxnmnzzkkscq45ua",<br>  "eu-amsterdam-1": "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaamwi2yxo5mbwbxydz5it4talwzkzfknywqcxuopi3suu575eu2rja",<br>  "eu-frankfurt-1": "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaapg6sk4uypeope6rsjdqgemtp7v4wu45din3eub47vfpwdjoymadq",<br>  "eu-madrid-1": "ocid1.image.oc1.eu-madrid-1.aaaaaaaaeoin77kq4jly4myzy7ap63iwmf6razdlftoyxvk7o2bcxnlyx56a",<br>  "eu-marseille-1": "ocid1.image.oc1.eu-marseille-1.aaaaaaaai5mwzo3turcncrh5zk2zbewqa7sn6fh26v74hosswed2zjuquj2q",<br>  "eu-milan-1": "ocid1.image.oc1.eu-milan-1.aaaaaaaasxksyjw24lp77uzemfqu2gtyledmksymjjom7m7d4koizg3goiza",<br>  "eu-paris-1": "ocid1.image.oc1.eu-paris-1.aaaaaaaagbmz6kz2it6ft64dgf7kvoevdy53soejx5ucudd5zwoifcavyh5q",<br>  "eu-stockholm-1": "ocid1.image.oc1.eu-stockholm-1.aaaaaaaast4rypafl2kho2g7nbqaec5tv3xdj4e5b6iuqdieurcionly2jna",<br>  "eu-zurich-1": "ocid1.image.oc1.eu-zurich-1.aaaaaaaajoochdylix7hfdf3e3kfsynhaztz5rtl3gacz6ke6ugw56icmuxa",<br>  "il-jerusalem-1": "ocid1.image.oc1.il-jerusalem-1.aaaaaaaaa2gspnrm6jdmxv4xqffjnvc5bu7xtmzptotcm2aygkvq3etwukkq",<br>  "me-abudhabi-1": "ocid1.image.oc1.me-abudhabi-1.aaaaaaaaghp5mezfrznk7yx5mfu5d75evrltrukaehkxzfmwlwn3vd47pxna",<br>  "me-dubai-1": "ocid1.image.oc1.me-dubai-1.aaaaaaaaxmqbxvp3tpa5rbp2swhfrmcbqok5vjhqhmqj6kmoy2c4j3olcgoq",<br>  "me-jeddah-1": "ocid1.image.oc1.me-jeddah-1.aaaaaaaa3o55xjoxggxzo3ufvzzyfpa26dx5fehernulxoctdir45hazyylq",<br>  "mx-monterrey-1": "ocid1.image.oc1.mx-monterrey-1.aaaaaaaaeasnsvrmjtnp2sa2emq2x63ixfdpq36mouj5qnz54x3yrsidiidq",<br>  "mx-queretaro-1": "ocid1.image.oc1.mx-queretaro-1.aaaaaaaawiewa5mlk7ty5ycfeqr77islx5ziiqm434kc35spf3ntazc6qahq",<br>  "sa-bogota-1": "ocid1.image.oc1.sa-bogota-1.aaaaaaaa4ogdfogwycxaxqhrngfd65rvahy4tcvjda2pgqggbfccjfpsvm6q",<br>  "sa-santiago-1": "ocid1.image.oc1.sa-santiago-1.aaaaaaaanrhvodnakgpu7f44w6oytaltc7x6pn6zirgri3ckyubcemlhpmxq",<br>  "sa-saopaulo-1": "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaax4w5f5dsgxbsnu2c6iuf6wbwtfekrisjrzb6a77nlun75ap33vbq",<br>  "sa-valparaiso-1": "ocid1.image.oc1.sa-valparaiso-1.aaaaaaaauwwidibcvn4kts3qmhy4qqxjuaa32fanvqlziv2vc2zyeaw4gmva",<br>  "sa-vinhedo-1": "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaalcyxi2by47atkj5pgmiwe3yiq4fe62i3nyhuqchgwmdtrfnxnhba",<br>  "uk-cardiff-1": "ocid1.image.oc1.uk-cardiff-1.aaaaaaaalkuehgqztca5mog32zcnhfnwx4xyn5pymvtcog2xbpcqfppdxxfa",<br>  "uk-london-1": "ocid1.image.oc1.uk-london-1.aaaaaaaadoqxyuecpc7z2oilbsorxypr4ssvkrvcsqnyoo5lciiel66wpsca",<br>  "us-ashburn-1": "ocid1.image.oc1.iad.aaaaaaaagxazxgs5mz5xglwm5i7a7pdphiu7f3h2u6njatz6akisfxdgjmwq",<br>  "us-chicago-1": "ocid1.image.oc1.us-chicago-1.aaaaaaaazn6piezti3khlsminniokag5cs7jiu3csqdiib3ex2jqv76qx3cq",<br>  "us-phoenix-1": "ocid1.image.oc1.phx.aaaaaaaafuu7f34bb6gzgbkif6nz5vhibhop4zugjjma723uhc562mplgfza",<br>  "us-sanjose-1": "ocid1.image.oc1.us-sanjose-1.aaaaaaaaapli23rbdkhfdejmayyckf7kfelei5ofn54jiunf7tcvpfsl4nuq"<br>}</pre> | no |
| <a name="input_instance_shape"></a> [instance\_shape](#input\_instance\_shape) | The shape of the instance | `string` | `"VM.Standard.A1.Flex"` | no |
| <a name="input_instance_shape_boot_volume_size_in_gbs"></a> [instance\_shape\_boot\_volume\_size\_in\_gbs](#input\_instance\_shape\_boot\_volume\_size\_in\_gbs) | The size of the boot volume in GBs | `string` | `"50"` | no |
| <a name="input_instance_shape_config_memory_in_gbs"></a> [instance\_shape\_config\_memory\_in\_gbs](#input\_instance\_shape\_config\_memory\_in\_gbs) | The amount of memory in GBs for the instance | `string` | `"24"` | no |
| <a name="input_instance_shape_config_ocpus"></a> [instance\_shape\_config\_ocpus](#input\_instance\_shape\_config\_ocpus) | The number of OCPUs for the instance | `string` | `"4"` | no |
| <a name="input_instance_shape_docker_volume_size_in_gbs"></a> [instance\_shape\_docker\_volume\_size\_in\_gbs](#input\_instance\_shape\_docker\_volume\_size\_in\_gbs) | The size of the docker volume in GBs | `string` | `"150"` | no |
| <a name="input_oracle_api_key_fingerprint"></a> [oracle\_api\_key\_fingerprint](#input\_oracle\_api\_key\_fingerprint) | The fingerprint of the public key | `string` | n/a | yes |
| <a name="input_oracle_api_private_key_path"></a> [oracle\_api\_private\_key\_path](#input\_oracle\_api\_private\_key\_path) | The path to the private key | `string` | `"~/.oci/oci_api_key.pem"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to deploy to | `string` | `"eu-milan-1"` | no |
| <a name="input_security_list_rules"></a> [security\_list\_rules](#input\_security\_list\_rules) | The security list rules | <pre>list(object({<br>    protocol  = string<br>    source    = string<br>    stateless = bool<br>    tcp_options = object({<br>      source_port_range = object({<br>        min = number<br>        max = number<br>      })<br>      min = number<br>      max = number<br>    })<br>    udp_options = object({<br>      source_port_range = object({<br>        min = number<br>        max = number<br>      })<br>      min = number<br>      max = number<br>    })<br>    icmp_options = object({<br>      type = number<br>      code = number<br>    })<br>  }))</pre> | <pre>[<br>  {<br>    "icmp_options": null,<br>    "protocol": "6",<br>    "source": "0.0.0.0/0",<br>    "stateless": false,<br>    "tcp_options": {<br>      "max": 22,<br>      "min": 22,<br>      "source_port_range": {<br>        "max": 65535,<br>        "min": 1<br>      }<br>    },<br>    "udp_options": null<br>  },<br>  {<br>    "icmp_options": null,<br>    "protocol": "17",<br>    "source": "0.0.0.0/0",<br>    "stateless": false,<br>    "tcp_options": null,<br>    "udp_options": {<br>      "max": 51820,<br>      "min": 51820,<br>      "source_port_range": {<br>        "max": 65535,<br>        "min": 1<br>      }<br>    }<br>  },<br>  {<br>    "icmp_options": {<br>      "code": 4,<br>      "type": 3<br>    },<br>    "protocol": "1",<br>    "source": "0.0.0.0/0",<br>    "stateless": false,<br>    "tcp_options": null,<br>    "udp_options": null<br>  }<br>]</pre> | no |
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
