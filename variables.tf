variable "oracle_api_key_fingerprint" {
  type        = string
  description = "The fingerprint of the public key"
}

variable "oracle_api_private_key_path" {
  type        = string
  description = "The path to the private key"
  default     = "~/.oci/oci_api_key.pem"
}

variable "ssh_public_key" {
  type        = string
  description = "The public key to use for SSH access"
  sensitive   = true
}

variable "additional_ssh_public_key" {
  type        = string
  description = "Additional public key to use for SSH access example: <<EOF > /home/ubuntu/.ssh/authorized_keys ssh-rsa AAAAB3NzaC1yc2EAA EOF"
  default     = ""
  sensitive   = true
}

variable "compartment_ocid" {
  type        = string
  description = "The OCID of the compartment"
  nullable    = false
}

variable "tenancy_ocid" {
  type        = string
  description = "The OCID of the tenancy"
  nullable    = false
}

variable "user_ocid" {
  type        = string
  description = "The OCID of the user to use for authentication"
  nullable    = false
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

variable "fault_domain" {
  type        = string
  description = "The fault domain to deploy to"
  default     = "FAULT-DOMAIN-2"
}

variable "instance_shape" {
  type        = string
  description = "The shape of the instance"
  default     = "VM.Standard.A1.Flex"
}

variable "instance_shape_config_memory_gb" {
  type        = string
  description = "The amount of memory in GBs for the instance"
  default     = "24"
}

variable "instance_shape_config_ocpus" {
  type        = string
  description = "The number of OCPUs for the instance"
  default     = "4"
}

variable "instance_shape_boot_volume_size_gb" {
  type        = string
  description = "The size of the boot volume in GBs"
  default     = "50"
}

variable "docker_volume_size_gb" {
  type        = string
  description = "The size of the docker volume in GBs"
  default     = "150"
}

variable "install_runtipi" {
  type        = bool
  description = "Install Homeserver Runtipi refs: https://runtipi.io/"
  default     = true
}

variable "runtipi_main_network_subnet" {
  type        = string
  description = "The subnet of the main network for Runtipi"
  default     = "172.18.0.0/16"
}

variable "runtipi_reverse_proxy_ip" {
  type        = string
  description = "The IP of the reverse proxy for Runtipi, WARNING: this IP should be in the subnet of the main network"
  default     = "172.18.0.254"
}

variable "runtipi_adguard_ip" {
  type        = string
  description = "The IP of the AdGuard for Runtipi, WARNING: this IP should be in the subnet of the main network and different from the reverse proxy IP"
  default     = "172.18.0.253"
}

variable "instance_image_ocids_by_region" {
  type        = map(string)
  description = "The OCID of the image to use for the instance"
  default = {
    # See https://docs.oracle.com/en-us/iaas/images/image/2c243e52-ed4b-4bc5-b7ce-2a94063d2a19/index.htm
    # Oracle-provided image "Canonical-Ubuntu-24.04-Minimal-aarch64-2024.10.08-0"
    af-johannesburg-1 = "ocid1.image.oc1.af-johannesburg-1.aaaaaaaafot57oc456xr2m6qg7auumzzlcrdqehitdceztk7cafwwwqr6rfa"
    ap-chuncheon-1    = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaa6s4f3ux4iqlidzupc6swhgxapaq4wp6e6rav2jcrntrq4xm5hboq"
    ap-hyderabad-1    = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaav2hw27anzikymein2qlui36oskhql4nk7uvg6ys2oy3isek45ncq"
    ap-melbourne-1    = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaajs7exfbxezdpvnyfvy3tb7nipyoyvvzpawcavr3lnluoabbw6fnq"
    ap-mumbai-1       = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaapj3j2y7ce7hx7mi5svv55xk56vt5gxv6m52fan53bjh3ylucuwiq"
    ap-osaka-1        = "ocid1.image.oc1.ap-osaka-1.aaaaaaaaldeqjomudapby2r4vqzkqpgfbltlzqdsoznfbrfy3oxhrro5lfha"
    ap-seoul-1        = "ocid1.image.oc1.ap-seoul-1.aaaaaaaaxcb4mkvnrbh67tsy7l2saxpggg47su4ieqqs47zajiksdevac4tq"
    ap-singapore-1    = "ocid1.image.oc1.ap-singapore-1.aaaaaaaazgpftr3dz6ycggdv3hzgeuigok6ppjo7tulyvt23dcifmraploiq"
    ap-sydney-1       = "ocid1.image.oc1.ap-sydney-1.aaaaaaaabren6pndzvk3zx6yvsrlvuytl252gfffngbmdnnqiju2ns3n53mq"
    ap-tokyo-1        = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaa7wfpiywco2qtsayxepkt6m72fki2fckhtk67hepa53lxdobmvucq"
    ca-montreal-1     = "ocid1.image.oc1.ca-montreal-1.aaaaaaaa6apcspvi563o3a3w72v5ke3rl73zd7ozwlpd7nddncdty46gwhaa"
    ca-toronto-1      = "ocid1.image.oc1.ca-toronto-1.aaaaaaaatyk4uxydfb6nld77djoh6unxvcjjwbhnuxyc66q2h2scq4kn2dsa"
    eu-amsterdam-1    = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaa7urvqgyy3qu5icptd2lq4yuyvhpnqedulxcnme7mq7f4pvxtbufq"
    eu-frankfurt-1    = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaax65kresevp22fzwqj3yy553ktmoekrhjmgx3p3p2tvk4hsw3vxmq"
    eu-madrid-1       = "ocid1.image.oc1.eu-madrid-1.aaaaaaaavc2jr2yqm7xxhthlhuae3aodwfvxhyjes5g4iimkr3irc3nhkf7q"
    eu-marseille-1    = "ocid1.image.oc1.eu-marseille-1.aaaaaaaaeahdract2jxrkpsgxgcrgllwkhxfyv4srx2a4jxfkzuqe37tb44a"
    eu-milan-1        = "ocid1.image.oc1.eu-milan-1.aaaaaaaa54frn7sjk7iuf7hy2kvcvz3bpgeodolqopyz2i4yrmv5riqoo52a"
    eu-paris-1        = "ocid1.image.oc1.eu-paris-1.aaaaaaaaabnylsroi62h56d34ulckcbmg3t3yu2qad2dhypmjs5qdfv7h5kq"
    eu-stockholm-1    = "ocid1.image.oc1.eu-stockholm-1.aaaaaaaalrpn2ma77pltnts5ipmtqnynlc5rnkrdjkvkcgwznlsu6xkybdcq"
    eu-zurich-1       = "ocid1.image.oc1.eu-zurich-1.aaaaaaaamrglec2vbss5tmteupwfhq47i5ts4zbhpyugilr55dhnkxwanaca"
    il-jerusalem-1    = "ocid1.image.oc1.il-jerusalem-1.aaaaaaaamq3zfigwidconwcgzx3nwmmt55svbbgujhsxnse74ia5ugggsjga"
    me-abudhabi-1     = "ocid1.image.oc1.me-abudhabi-1.aaaaaaaan2eszzdrwqft754ghcce637x2wmmtv7xz4s5lfe4lpiuj4einsvq"
    me-dubai-1        = "ocid1.image.oc1.me-dubai-1.aaaaaaaaxwsbrnl45fqc5awpv2vksx2gxwnyhv4dffigcpnscq7znhmljdbq"
    me-jeddah-1       = "ocid1.image.oc1.me-jeddah-1.aaaaaaaahsee5b75qh3fpvtcxty26knl7mtchuh2gwvmclnytvhqwvblnhga"
    mx-monterrey-1    = "ocid1.image.oc1.mx-monterrey-1.aaaaaaaattmfisdlui4cqrgytayqp47oqponuukb5754lv4ol7zwmnhixy6a"
    mx-queretaro-1    = "ocid1.image.oc1.mx-queretaro-1.aaaaaaaaaibqfitupdgsk3qozwfxrv7fal4t5u6gujemkdzqv56ado2ytidq"
    sa-bogota-1       = "ocid1.image.oc1.sa-bogota-1.aaaaaaaaef37yvccm356ekf6c4vjfxcp7amjsubrus7f5yzowepelwfwdd7q"
    sa-santiago-1     = "ocid1.image.oc1.sa-santiago-1.aaaaaaaascdz5oprkbvtxvylajktpjvy6bzffvv6pxzsnhib7tlm6e3x4xja"
    sa-saopaulo-1     = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaaw2n2h7zt4mxamzw4upmzh5djd3bdcukvpyp2kiozooxdwxumzsfq"
    sa-valparaiso-1   = "ocid1.image.oc1.sa-valparaiso-1.aaaaaaaae37edjvawkov7m4saxlbt25zl4n65cgnj4hap6vncpv2ttv4bzma"
    sa-vinhedo-1      = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaatrwlgkiptlh34l65net44k2tmv4zh2chvmzw7jhommsvfe72qg3q"
    uk-cardiff-1      = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaavjb6ajzjfwk2zlliuzoetyhfvhqhpo6hxyur77ai4ebjrprlyhda"
    uk-london-1       = "ocid1.image.oc1.uk-london-1.aaaaaaaa4z7qr5ccidp4dowvqrb65v4qnrmzmx346q7gkvsbw6vfwxh6bkfq"
    us-ashburn-1      = "ocid1.image.oc1.iad.aaaaaaaa5rxxb24tifnuklbdr3uqe3jnoeojal5evtkwysu37m6sxnod2rqa"
    us-chicago-1      = "ocid1.image.oc1.us-chicago-1.aaaaaaaa64e73jfbns5ivnphb2oqyfqvuumbghlfouvudebolh4yev6gckdq"
    us-phoenix-1      = "ocid1.image.oc1.phx.aaaaaaaame5af3onauf35n5nth4efynuag67gkakivhvp26othxzjfvj4ria"
    us-sanjose-1      = "ocid1.image.oc1.us-sanjose-1.aaaaaaaagqsk2tvjwnkkarmct7bzmzez6v4cnqtsueca2lhg6lsfeji36qcq"
  }
}

variable "security_list_rules" {
  description = "The security list rules"
  type = list(object({
    protocol  = string
    source    = string
    stateless = bool
    tcp_options = object({
      source_port_range = object({
        min = number
        max = number
      })
      min = number
      max = number
    })
    udp_options = object({
      source_port_range = object({
        min = number
        max = number
      })
      min = number
      max = number
    })
    icmp_options = object({
      type = number
      code = number
    })
  }))
  default = [
    {
      protocol  = "6"
      source    = "0.0.0.0/0"
      stateless = false
      tcp_options = {
        source_port_range = {
          min = 1
          max = 65535
        }
        min = 22
        max = 22
      }
      udp_options  = null
      icmp_options = null
    },
    {
      protocol    = "17"
      source      = "0.0.0.0/0"
      stateless   = false
      tcp_options = null
      udp_options = {
        source_port_range = {
          min = 1
          max = 65535
        }
        min = 51820
        max = 51820
      }
      icmp_options = null
    },
    {
      protocol    = "1"
      source      = "0.0.0.0/0"
      stateless   = false
      tcp_options = null
      udp_options = null
      icmp_options = {
        type = 3
        code = 4
      }
    }
  ]
}

variable "wireguard_client_configuration" {
  type        = string
  description = "Adding a valid configuration for a WireGuard client will automatically install and configure it on the virtual machine. Example:<<EOF\n\n[Interface]\nPrivateKey = aaaaaaaaaaaaaaa\nAddress = 1.2.3.4/24\nDNS = 5.6.7.8\nDNS = 9.1.1.1\n\n[Peer]\nPublicKey = bbbbbbbbbbbbbbbbbb\nPresharedKey = ccccccccccccccc\nAllowedIPs = 0.0.0.0/24\nEndpoint = dddddddddddddd\nPersistentKeepalive = 25\nEOF"
  default     = ""
  sensitive   = true
  validation {
    condition     = var.wireguard_client_configuration == "" || can(regex("^\\[Interface\\]", var.wireguard_client_configuration))
    error_message = "WireGuard configuration must start with [Interface] section or be empty."
  }
}
