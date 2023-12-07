Creating a Terraform Module for Oracle Cloud Free Tier Virtual Machine

# Terraform Module: Oracle Cloud Free Tier Virtual Machine

This Terraform module allows you to create a virtual machine (VM) on Oracle Cloud that falls within the Oracle Cloud Free Tier. By using this module, you can easily provision a VM with the necessary configurations while staying within the free usage limits.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | 5.22.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | 5.22.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_core_default_route_table.default_route_table](https://registry.terraform.io/providers/oracle/oci/5.22.0/docs/resources/core_default_route_table) | resource |
| [oci_core_instance.instance](https://registry.terraform.io/providers/oracle/oci/5.22.0/docs/resources/core_instance) | resource |
| [oci_core_internet_gateway.internet_gateway](https://registry.terraform.io/providers/oracle/oci/5.22.0/docs/resources/core_internet_gateway) | resource |
| [oci_core_public_ip.public_ip](https://registry.terraform.io/providers/oracle/oci/5.22.0/docs/resources/core_public_ip) | resource |
| [oci_core_security_list.security_list](https://registry.terraform.io/providers/oracle/oci/5.22.0/docs/resources/core_security_list) | resource |
| [oci_core_subnet.subnet](https://registry.terraform.io/providers/oracle/oci/5.22.0/docs/resources/core_subnet) | resource |
| [oci_core_vcn.vcn](https://registry.terraform.io/providers/oracle/oci/5.22.0/docs/resources/core_vcn) | resource |
| [oci_core_volume.docker_volume](https://registry.terraform.io/providers/oracle/oci/5.22.0/docs/resources/core_volume) | resource |
| [oci_core_volume_attachment.docker_volume_attachment](https://registry.terraform.io/providers/oracle/oci/5.22.0/docs/resources/core_volume_attachment) | resource |
| [oci_core_volume_backup_policy.docker_volume_backup_policy](https://registry.terraform.io/providers/oracle/oci/5.22.0/docs/resources/core_volume_backup_policy) | resource |
| [oci_core_volume_backup_policy_assignment.docker_volume_backup_policy_assignment](https://registry.terraform.io/providers/oracle/oci/5.22.0/docs/resources/core_volume_backup_policy_assignment) | resource |
| [oci_core_private_ips.instance_private_ip](https://registry.terraform.io/providers/oracle/oci/5.22.0/docs/data-sources/core_private_ips) | data source |
| [oci_core_vnic.instance_vnic](https://registry.terraform.io/providers/oracle/oci/5.22.0/docs/data-sources/core_vnic) | data source |
| [oci_core_vnic_attachments.instance_vnics](https://registry.terraform.io/providers/oracle/oci/5.22.0/docs/data-sources/core_vnic_attachments) | data source |
| [oci_identity_availability_domain.ad](https://registry.terraform.io/providers/oracle/oci/5.22.0/docs/data-sources/identity_availability_domain) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_ssh_public_key"></a> [additional\_ssh\_public\_key](#input\_additional\_ssh\_public\_key) | Additional public key to use for SSH access example: <<EOF > /home/ubuntu/.ssh/authorized\_keys ssh-rsa AAAAB3NzaC1yc2EAA EOF | `string` | `""` | no |
| <a name="input_availability_domain_number"></a> [availability\_domain\_number](#input\_availability\_domain\_number) | The availability domain number | `number` | `1` | no |
| <a name="input_compartment_ocid"></a> [compartment\_ocid](#input\_compartment\_ocid) | The OCID of the compartment | `string` | n/a | yes |
| <a name="input_instance_display_name"></a> [instance\_display\_name](#input\_instance\_display\_name) | The display name of the instance | `string` | `"DockerHost"` | no |
| <a name="input_instance_image_ocid"></a> [instance\_image\_ocid](#input\_instance\_image\_ocid) | n/a | `map(any)` | <pre>{<br>  "af-johannesburg-1": "ocid1.image.oc1.af-johannesburg-1.aaaaaaaayr7olrkwsywgxwznyiypnwcwjh66kjz37b5srp5lsciqzds6fy6q",<br>  "ap-chuncheon-1": "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaagn7tnetjt3r7qxn74kypb6gyfcsh2t3kwbljzmm62hr2qlowttxq",<br>  "ap-hyderabad-1": "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaar5rawf6psuetovqo2shgmg57luphw3ihejcuhkznnoesezckgpca",<br>  "ap-melbourne-1": "ocid1.image.oc1.ap-melbourne-1.aaaaaaaatms7n733avabecvupvyq3skjdtyvzznxbfbqamesny3bbunwwx2q",<br>  "ap-mumbai-1": "ocid1.image.oc1.ap-mumbai-1.aaaaaaaafpthmkvrokvfimled5btpksd5raurhsabommgfygrynw5zfydg3q",<br>  "ap-osaka-1": "ocid1.image.oc1.ap-osaka-1.aaaaaaaa67n74wtxv7hamkpvjc5nrtqb4w2mqisusg46d77zp24cchk244wq",<br>  "ap-seoul-1": "ocid1.image.oc1.ap-seoul-1.aaaaaaaa6skd222zi3ivkke3pz7bxqwikxdp73w5imhjssrr3qv3ya2toera",<br>  "ap-singapore-1": "ocid1.image.oc1.ap-singapore-1.aaaaaaaaocagesx3qky63sisclxb47hbmkutctlqyplwnnsfqltliri2v2ka",<br>  "ap-sydney-1": "ocid1.image.oc1.ap-sydney-1.aaaaaaaacuk7uab3nq22indgjsm6r6nryvbvjng375woaiz2vuwf6r7qfuna",<br>  "ap-tokyo-1": "ocid1.image.oc1.ap-tokyo-1.aaaaaaaav5hvfyet6jx5ys7b4eil7qm4tgdvxcek3zfm45na3rhbfisfwjpq",<br>  "ca-montreal-1": "ocid1.image.oc1.ca-montreal-1.aaaaaaaakjerkgbhiww3pglpipxbh4wmdvvpf22nawoog5uefcpsoobuh7za",<br>  "ca-toronto-1": "ocid1.image.oc1.ca-toronto-1.aaaaaaaaj435kez3bh2xfko63cmyxjo3ig4wkiq564opmv4eptiroypcjcma",<br>  "eu-amsterdam-1": "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaav4k3bt57ntis62ahfa56j5zci2xdg2yhashwh6q5k35ucpw7m2dq",<br>  "eu-frankfurt-1": "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa5ogkqtzgjbo7bazv5l3re3yxcc6iifu5waavjqzc2s6iqm4lw2ia",<br>  "eu-madrid-1": "ocid1.image.oc1.eu-madrid-1.aaaaaaaacjvjivw2646yxiwetlr3as3xqsgqbbdijmnvdap43r44chbssuka",<br>  "eu-marseille-1": "ocid1.image.oc1.eu-marseille-1.aaaaaaaanhsmnxu76u6tki2g52m7swmhn7wemvh7omtuw5pofefctyobthhq",<br>  "eu-milan-1": "ocid1.image.oc1.eu-milan-1.aaaaaaaad3j7uywpk4jwlvdkpocjuc77mhong637pguaewspkf4ehxnic3aq",<br>  "eu-paris-1": "ocid1.image.oc1.eu-paris-1.aaaaaaaautyng5nv2yqff7it3incvifa7m7wwyymwyt7iabg6tcymrmg6cmq",<br>  "eu-stockholm-1": "ocid1.image.oc1.eu-stockholm-1.aaaaaaaavn7a3eg2pwjs7vnuj4iuuioqklrabygfzn2huqcjrxbnfobuyeya",<br>  "eu-zurich-1": "ocid1.image.oc1.eu-zurich-1.aaaaaaaa7rcmbgbl2sfn4oqsbg3juqgvligm52yyegebajb7eo6i7nybbegq",<br>  "il-jerusalem-1": "ocid1.image.oc1.il-jerusalem-1.aaaaaaaany743ypyvtrra55dw6ckkoydc53wxdjufaxiikpv3woakb3iricq",<br>  "me-abudhabi-1": "ocid1.image.oc1.me-abudhabi-1.aaaaaaaaqzlprpy4yprynuks242oxkko4rgiofkm5zga6hn7rs2ns5o5nxfq",<br>  "me-dubai-1": "ocid1.image.oc1.me-dubai-1.aaaaaaaaz2atnyu3qlgabmi2ioyts3zihemshxgl3hw6th6whg6ho5dizzjq",<br>  "me-jeddah-1": "ocid1.image.oc1.me-jeddah-1.aaaaaaaaot3yo4s6byxfic3xu4excsa6r73twhrsfrohdj3bodgfbndp54na",<br>  "mx-queretaro-1": "ocid1.image.oc1.mx-queretaro-1.aaaaaaaapbwwik6m7pbfo6vt25gwkqaysffnbjeqdxve2f7tboqzyvqfnubq",<br>  "sa-santiago-1": "ocid1.image.oc1.sa-santiago-1.aaaaaaaaxmovw3ir5mutoi2rtfd55qqew5kizuk74dm44xbqpjpoq2k5zwuq",<br>  "sa-saopaulo-1": "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaasgdn7mttxohdxv2aorkllmjpb6da43sbojpnv4el6mmp4f37wanq",<br>  "sa-vinhedo-1": "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaad6jcyexupdegr4zaubevwxgotxih2d3gvzl6vpt5hsc66l3xfkeq",<br>  "uk-cardiff-1": "ocid1.image.oc1.uk-cardiff-1.aaaaaaaaibtfqkzvy7r7kvd7wpmbt5f3cu7bcxcpiiekru2hrfsnnjtie3uq",<br>  "uk-london-1": "ocid1.image.oc1.uk-london-1.aaaaaaaapqvy5cln3muczrzgic2uwcy4u7bgu6hlhmx5pd363gyvesptm63a",<br>  "us-ashburn-1": "ocid1.image.oc1.iad.aaaaaaaauecuylimto4aqvfsszeazaprorqejoh6ttuupsdks723z2diu5fq",<br>  "us-chicago-1": "ocid1.image.oc1.us-chicago-1.aaaaaaaavgwin5uvme4ycwt6igr6a3zoykiuu3nbbgvr674cm7afbsotsh4a",<br>  "us-phoenix-1": "ocid1.image.oc1.phx.aaaaaaaa4iks3c6emzj2gshvwmsnheutndb2gzfvyst6jfvr5basm4cqzqeq",<br>  "us-sanjose-1": "ocid1.image.oc1.us-sanjose-1.aaaaaaaara5hwkhromkbdp6kof77koicopxw34zt5v5lnqejz72xa6ixjl6q"<br>}</pre> | no |
| <a name="input_instance_shape"></a> [instance\_shape](#input\_instance\_shape) | The shape of the instance | `string` | `"VM.Standard.A1.Flex"` | no |
| <a name="input_instance_shape_boot_volume_size_in_gbs"></a> [instance\_shape\_boot\_volume\_size\_in\_gbs](#input\_instance\_shape\_boot\_volume\_size\_in\_gbs) | The size of the boot volume in GBs | `string` | `"50"` | no |
| <a name="input_instance_shape_config_memory_in_gbs"></a> [instance\_shape\_config\_memory\_in\_gbs](#input\_instance\_shape\_config\_memory\_in\_gbs) | The amount of memory in GBs for the instance | `string` | `"24"` | no |
| <a name="input_instance_shape_config_ocpus"></a> [instance\_shape\_config\_ocpus](#input\_instance\_shape\_config\_ocpus) | The number of OCPUs for the instance | `string` | `"4"` | no |
| <a name="input_instance_shape_docker_volume_size_in_gbs"></a> [instance\_shape\_docker\_volume\_size\_in\_gbs](#input\_instance\_shape\_docker\_volume\_size\_in\_gbs) | The size of the docker volume in GBs | `string` | `"150"` | no |
| <a name="input_oracle_api_key_fingerprint"></a> [oracle\_api\_key\_fingerprint](#input\_oracle\_api\_key\_fingerprint) | The fingerprint of the public key | `string` | n/a | yes |
| <a name="input_oracle_api_private_key_path"></a> [oracle\_api\_private\_key\_path](#input\_oracle\_api\_private\_key\_path) | The path to the private key | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to deploy to | `string` | `"eu-milan-1"` | no |
| <a name="input_ssh_private_key_path"></a> [ssh\_private\_key\_path](#input\_ssh\_private\_key\_path) | The path to the private key | `string` | n/a | yes |
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
