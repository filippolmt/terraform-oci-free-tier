variable "oracle_api_key_fingerprint" {
  type        = string
  description = "The fingerprint of the public key"
}

variable "oracle_api_private_key_path" {
  type        = string
  description = "The path to the private key"
}

variable "ssh_public_key" {
  type        = string
  description = "The public key to use for SSH access"
}

variable "additional_ssh_public_key" {
  type        = string
  description = "Additional public key to use for SSH access example: <<EOF > /home/ubuntu/.ssh/authorized_keys ssh-rsa AAAAB3NzaC1yc2EAA EOF"
  default     = ""
}

variable "ssh_private_key_path" {
  type        = string
  description = "The path to the private key"
}

variable "compartment_ocid" {
  type        = string
  description = "The OCID of the compartment"
}

variable "tenancy_ocid" {
  type        = string
  description = "The OCID of the tenancy"
}

variable "user_ocid" {
  type        = string
  description = "The OCID of the user to use for authentication"
}

variable "region" {
  type        = string
  description = "The region to deploy to"
  default     = "eu-milan-1"
}

variable "instance_display_name" {
  type        = string
  description = "The display name of the instance"
  default     = "DockerHost"
}

variable "vcn_cidr_block" {
  type        = string
  description = "The CIDR block for the VCN"
  default     = "10.1.0.0/16"
}

variable "availability_domain_number" {
  type        = number
  description = "The availability domain number"
  default     = 1
}

variable "instance_shape" {
  type        = string
  description = "The shape of the instance"
  default     = "VM.Standard.A1.Flex"
}
variable "instance_shape_config_memory_in_gbs" {
  type        = string
  description = "The amount of memory in GBs for the instance"
  default     = "24"
}
variable "instance_shape_config_ocpus" {
  type        = string
  description = "The number of OCPUs for the instance"
  default     = "4"
}

variable "instance_shape_boot_volume_size_in_gbs" {
  type        = string
  description = "The size of the boot volume in GBs"
  default     = "50"
}

variable "instance_shape_docker_volume_size_in_gbs" {
  type        = string
  description = "The size of the docker volume in GBs"
  default     = "150"
}

variable "instance_image_ocid" {
  type = map(any)

  default = {
    # See https://docs.oracle.com/en-us/iaas/images/image/04b8f49e-4a3a-4154-ba2f-18435b15b328/
    # Oracle-provided image "Canonical-Ubuntu-22.04-Minimal-aarch64-2023.08.27-0"
    af-johannesburg-1 = "ocid1.image.oc1.af-johannesburg-1.aaaaaaaayr7olrkwsywgxwznyiypnwcwjh66kjz37b5srp5lsciqzds6fy6q"
    ap-chuncheon-1    = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaagn7tnetjt3r7qxn74kypb6gyfcsh2t3kwbljzmm62hr2qlowttxq"
    ap-hyderabad-1    = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaar5rawf6psuetovqo2shgmg57luphw3ihejcuhkznnoesezckgpca"
    ap-melbourne-1    = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaatms7n733avabecvupvyq3skjdtyvzznxbfbqamesny3bbunwwx2q"
    ap-mumbai-1       = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaafpthmkvrokvfimled5btpksd5raurhsabommgfygrynw5zfydg3q"
    ap-osaka-1        = "ocid1.image.oc1.ap-osaka-1.aaaaaaaa67n74wtxv7hamkpvjc5nrtqb4w2mqisusg46d77zp24cchk244wq"
    ap-seoul-1        = "ocid1.image.oc1.ap-seoul-1.aaaaaaaa6skd222zi3ivkke3pz7bxqwikxdp73w5imhjssrr3qv3ya2toera"
    ap-singapore-1    = "ocid1.image.oc1.ap-singapore-1.aaaaaaaaocagesx3qky63sisclxb47hbmkutctlqyplwnnsfqltliri2v2ka"
    ap-sydney-1       = "ocid1.image.oc1.ap-sydney-1.aaaaaaaacuk7uab3nq22indgjsm6r6nryvbvjng375woaiz2vuwf6r7qfuna"
    ap-tokyo-1        = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaav5hvfyet6jx5ys7b4eil7qm4tgdvxcek3zfm45na3rhbfisfwjpq"
    ca-montreal-1     = "ocid1.image.oc1.ca-montreal-1.aaaaaaaakjerkgbhiww3pglpipxbh4wmdvvpf22nawoog5uefcpsoobuh7za"
    ca-toronto-1      = "ocid1.image.oc1.ca-toronto-1.aaaaaaaaj435kez3bh2xfko63cmyxjo3ig4wkiq564opmv4eptiroypcjcma"
    eu-amsterdam-1    = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaav4k3bt57ntis62ahfa56j5zci2xdg2yhashwh6q5k35ucpw7m2dq"
    eu-frankfurt-1    = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa5ogkqtzgjbo7bazv5l3re3yxcc6iifu5waavjqzc2s6iqm4lw2ia"
    eu-madrid-1       = "ocid1.image.oc1.eu-madrid-1.aaaaaaaacjvjivw2646yxiwetlr3as3xqsgqbbdijmnvdap43r44chbssuka"
    eu-marseille-1    = "ocid1.image.oc1.eu-marseille-1.aaaaaaaanhsmnxu76u6tki2g52m7swmhn7wemvh7omtuw5pofefctyobthhq"
    eu-milan-1        = "ocid1.image.oc1.eu-milan-1.aaaaaaaad3j7uywpk4jwlvdkpocjuc77mhong637pguaewspkf4ehxnic3aq"
    eu-paris-1        = "ocid1.image.oc1.eu-paris-1.aaaaaaaautyng5nv2yqff7it3incvifa7m7wwyymwyt7iabg6tcymrmg6cmq"
    eu-stockholm-1    = "ocid1.image.oc1.eu-stockholm-1.aaaaaaaavn7a3eg2pwjs7vnuj4iuuioqklrabygfzn2huqcjrxbnfobuyeya"
    eu-zurich-1       = "ocid1.image.oc1.eu-zurich-1.aaaaaaaa7rcmbgbl2sfn4oqsbg3juqgvligm52yyegebajb7eo6i7nybbegq"
    il-jerusalem-1    = "ocid1.image.oc1.il-jerusalem-1.aaaaaaaany743ypyvtrra55dw6ckkoydc53wxdjufaxiikpv3woakb3iricq"
    me-abudhabi-1     = "ocid1.image.oc1.me-abudhabi-1.aaaaaaaaqzlprpy4yprynuks242oxkko4rgiofkm5zga6hn7rs2ns5o5nxfq"
    me-dubai-1        = "ocid1.image.oc1.me-dubai-1.aaaaaaaaz2atnyu3qlgabmi2ioyts3zihemshxgl3hw6th6whg6ho5dizzjq"
    me-jeddah-1       = "ocid1.image.oc1.me-jeddah-1.aaaaaaaaot3yo4s6byxfic3xu4excsa6r73twhrsfrohdj3bodgfbndp54na"
    mx-queretaro-1    = "ocid1.image.oc1.mx-queretaro-1.aaaaaaaapbwwik6m7pbfo6vt25gwkqaysffnbjeqdxve2f7tboqzyvqfnubq"
    sa-santiago-1     = "ocid1.image.oc1.sa-santiago-1.aaaaaaaaxmovw3ir5mutoi2rtfd55qqew5kizuk74dm44xbqpjpoq2k5zwuq"
    sa-saopaulo-1     = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaasgdn7mttxohdxv2aorkllmjpb6da43sbojpnv4el6mmp4f37wanq"
    sa-vinhedo-1      = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaad6jcyexupdegr4zaubevwxgotxih2d3gvzl6vpt5hsc66l3xfkeq"
    uk-cardiff-1      = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaaibtfqkzvy7r7kvd7wpmbt5f3cu7bcxcpiiekru2hrfsnnjtie3uq"
    uk-london-1       = "ocid1.image.oc1.uk-london-1.aaaaaaaapqvy5cln3muczrzgic2uwcy4u7bgu6hlhmx5pd363gyvesptm63a"
    us-ashburn-1      = "ocid1.image.oc1.iad.aaaaaaaauecuylimto4aqvfsszeazaprorqejoh6ttuupsdks723z2diu5fq"
    us-chicago-1      = "ocid1.image.oc1.us-chicago-1.aaaaaaaavgwin5uvme4ycwt6igr6a3zoykiuu3nbbgvr674cm7afbsotsh4a"
    us-phoenix-1      = "ocid1.image.oc1.phx.aaaaaaaa4iks3c6emzj2gshvwmsnheutndb2gzfvyst6jfvr5basm4cqzqeq"
    us-sanjose-1      = "ocid1.image.oc1.us-sanjose-1.aaaaaaaara5hwkhromkbdp6kof77koicopxw34zt5v5lnqejz72xa6ixjl6q"
  }
}
