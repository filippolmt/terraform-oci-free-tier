variable "oracle_api_key_fingerprint" {
  type        = string
  description = "The fingerprint of the OCI API public key"
}

variable "oracle_api_private_key_path" {
  type        = string
  description = "The path to the OCI API private key file"
  default     = "~/.oci/oci_api_key.pem"
}

variable "ssh_public_key" {
  type        = string
  description = "The public key to use for SSH access"
  sensitive   = true
}

variable "additional_ssh_public_key" {
  type        = string
  description = "Additional SSH public key to add to authorized_keys (optional)"
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
  description = "The OCI region to deploy resources"
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

variable "subnet_cidr_block" {
  type        = string
  description = "The CIDR block for the subnet (must be within VCN CIDR)"
  default     = "10.1.0.0/24"
}

variable "kms_key_id" {
  type        = string
  description = "The OCID of the KMS key to use for volume encryption. If null, volumes will not be encrypted with customer-managed keys."
  default     = null
}

variable "freeform_tags" {
  type        = map(string)
  description = "Freeform tags to apply to all resources"
  default = {
    "ManagedBy" = "Terraform"
  }
}

variable "availability_domain_number" {
  type        = number
  description = "The availability domain number (1-3 depending on region)"
  default     = 1
}

variable "fault_domain" {
  type        = string
  description = "The fault domain for the instance (FAULT-DOMAIN-1, FAULT-DOMAIN-2, or FAULT-DOMAIN-3)"
  default     = "FAULT-DOMAIN-2"
}

variable "instance_shape" {
  type        = string
  description = "The OCI compute shape (VM.Standard.A1.Flex for Free Tier ARM instances)"
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
  description = "The size of the secondary block volume in GBs (mounted at /mnt/data for Docker data)"
  default     = "150"
}

variable "install_runtipi" {
  type        = bool
  description = "Whether to install RunTipi homeserver (https://runtipi.io)"
  default     = true
}

variable "runtipi_main_network_subnet" {
  type        = string
  description = "The Docker network subnet for RunTipi containers"
  default     = "172.18.0.0/16"
}

variable "runtipi_reverse_proxy_ip" {
  type        = string
  description = "The static IP for RunTipi reverse proxy (Traefik). Must be within runtipi_main_network_subnet"
  default     = "172.18.0.254"
}

variable "runtipi_adguard_ip" {
  type        = string
  description = "The static IP for AdGuard. Must be within runtipi_main_network_subnet and different from reverse proxy IP"
  default     = "172.18.0.253"
}

variable "instance_image_ocids_by_region" {
  type        = map(string)
  description = "Map of OCI region to Ubuntu 24.04 ARM64 image OCID"
  default = {
    # See https://docs.oracle.com/en-us/iaas/images/
    # Canonical Ubuntu 24.04 Minimal for ARM64: https://docs.oracle.com/en-us/iaas/images/ubuntu-2404/canonical-ubuntu-24-04-minimal-aarch64-2025-09-22-0.htm

    af-johannesburg-1 = "ocid1.image.oc1.af-johannesburg-1.aaaaaaaak5nlhyhiwafbxjhlreejewizjs7nhod257vja2eh6vkernjckbja"
    ap-chuncheon-1    = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaabectst4fkxq5avpaf4dstmemodqmdo5txhs3632etb34vuer6ajq"
    ap-hyderabad-1    = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaajrplcfdj6tfe7hsnyxvd2mi6rny2qqxnvd33xcaz236yt2vwd6ga"
    ap-melbourne-1    = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaarbrgko6mxlnkc7ygr6pvm57mhldu375o44g7r5ph5khg44zwssoq"
    ap-mumbai-1       = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaa3ijqnvqa6hwhl3xu2eiqydzx77ukfu6rafhxfhqhemwugvci6gxa"
    ap-osaka-1        = "ocid1.image.oc1.ap-osaka-1.aaaaaaaa32nht45vu6d4xf3dlqydt2k2zghlds3fzdm5oidnonjgrhuon6fa"
    ap-seoul-1        = "ocid1.image.oc1.ap-seoul-1.aaaaaaaacmscv6qm77y3zqudoyrlt4552gubvrfoui7efp64kuqgeir4s3oq"
    ap-singapore-1    = "ocid1.image.oc1.ap-singapore-1.aaaaaaaas6w45vtj7baofaex5q3sukv2idpn2bchseh3zvkg4mzygmeafu2q"
    ap-sydney-1       = "ocid1.image.oc1.ap-sydney-1.aaaaaaaae2z2lh5w2oc6hw67tgl3azrlhcfhipjqtxpt264gtdlyaxc6vaaq"
    ap-tokyo-1        = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaalryqosses53brtxfexpfipf5ynu6pkyjr3ge4qfp6o4fijw5ufzq"
    ca-montreal-1     = "ocid1.image.oc1.ca-montreal-1.aaaaaaaaolt2nqgxdh7mhvyzikp7gzv5m6tny6qaogct3vt47qtwzjaactdq"
    ca-toronto-1      = "ocid1.image.oc1.ca-toronto-1.aaaaaaaabt3juibcfbfeuebkpvnpewvegbp73gzcyomcjatxgj47sj37yxpq"
    eu-amsterdam-1    = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaae7inuayr2d33djwyagj4vp7nhd6tkzdql7bs4shiypeiimhaiusq"
    eu-frankfurt-1    = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaafb2sye3yjqkh3ejoeindkf2jgbgo2cciffs6sbwnpbgvclz6q5zq"
    eu-madrid-1       = "ocid1.image.oc1.eu-madrid-1.aaaaaaaacxmqpivwimu5jo6tu74du272itlj66zmo5i5yhsuh6cfurflyuaa"
    eu-marseille-1    = "ocid1.image.oc1.eu-marseille-1.aaaaaaaalqlrae7xkknyorkhptgxgofu3gxpr7d3umm4stjwdm7p6ae4ygma"
    eu-milan-1        = "ocid1.image.oc1.eu-milan-1.aaaaaaaaq4bgs3zvqpowagemvdn273poop5vlwdls2isccsrhphekmhe6mma"
    eu-paris-1        = "ocid1.image.oc1.eu-paris-1.aaaaaaaados7dqzmqbrsgtveuc5sgizkceosa652dgwh5rqcigobci3gyxxa"
    eu-stockholm-1    = "ocid1.image.oc1.eu-stockholm-1.aaaaaaaaptkd6ru6chhcbdvuucqhvo57365zsr2gneiujccq3ku7fet3axoa"
    eu-zurich-1       = "ocid1.image.oc1.eu-zurich-1.aaaaaaaalujwiioxws4mnipycn5vidqecrrua4kji43a4upmmrsknhxsuqna"
    il-jerusalem-1    = "ocid1.image.oc1.il-jerusalem-1.aaaaaaaah4pjacbzz4h43yrof6nu5jardm32o4qtf4okuvrxagrihesu5vuq"
    me-abudhabi-1     = "ocid1.image.oc1.me-abudhabi-1.aaaaaaaapxqovvd6m2nkm2nrgzy7wsj5qjbb2j4yiozmoyw7tv3ol7c5kykq"
    me-dubai-1        = "ocid1.image.oc1.me-dubai-1.aaaaaaaa5tu7ioxcwtlolpbirzlusintftwniris5drsimxod3yow3uv2vxa"
    me-jeddah-1       = "ocid1.image.oc1.me-jeddah-1.aaaaaaaaevyhfuwgnfykdjrxi2myvahwpeysms3p2p66l326mx6bznfccyaa"
    mx-monterrey-1    = "ocid1.image.oc1.mx-monterrey-1.aaaaaaaaoc2qwggifssdczjafywxq5jke4qfhxylwhgdytzhimu2dvcyc3ua"
    mx-queretaro-1    = "ocid1.image.oc1.mx-queretaro-1.aaaaaaaaoea6l3ycev6sqelqr2ubsstaqmbh4zd6gd4wndvjwlfid5xm3eqa"
    sa-bogota-1       = "ocid1.image.oc1.sa-bogota-1.aaaaaaaatqyy2dfmajvult6mqtkl3bb4timvj6p2l3wvjo3rx25ycby3tyga"
    sa-santiago-1     = "ocid1.image.oc1.sa-santiago-1.aaaaaaaajhisswibdmpgchjvplqrsj4j52qysejm7gf3ypzism57ouyztzwa"
    sa-saopaulo-1     = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaaogxf4iaptvdbpdsnw6yhq75ielbqb3iszryvtzekhce2dhl4okia"
    sa-valparaiso-1   = "ocid1.image.oc1.sa-valparaiso-1.aaaaaaaaibiuvwkfiv4mdx6ugrjyxt7pwxxf5fsijuvnpwe4r7x2wz23vxha"
    sa-vinhedo-1      = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaazhjq6mqh32iy5suhgrsotkwyfe7ngxkz3sjc7ykwjydyn4v7eljq"
    uk-cardiff-1      = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaanydredih3rrjj2qkyt7zhdczfsuyrtdwdzbfaoy67mxuvyaz4g3q"
    uk-london-1       = "ocid1.image.oc1.uk-london-1.aaaaaaaaiqj4r4akxsvm25b5ky2fw6jd2bytcktj7ub3ar7muxrbgdbyo2wa"
    us-ashburn-1      = "ocid1.image.oc1.iad.aaaaaaaaoxcb6yp3brpepe726ar3bsadhbs3mqrn6cyaeq2dneo75opgfija"
    us-chicago-1      = "ocid1.image.oc1.us-chicago-1.aaaaaaaa3oczz5wayypofsav2lnjfsw3iwh47t3vijjn6jx5ptejfgbatmiq"
    us-phoenix-1      = "ocid1.image.oc1.phx.aaaaaaaarwjbs4jfdqbwsf24tqxv2c7ca5q4zwswesglupowndgnqmkio56q"
    us-sanjose-1      = "ocid1.image.oc1.us-sanjose-1.aaaaaaaaojmqa2wacgixftl4xvkvvjkyx455cnetuigp4qgord5gokknwlaa"
  }
}

variable "ingress_security_rules" {
  description = "List of ingress (inbound) security rules for the VCN security list"
  type = list(object({
    description = string
    protocol    = string
    source      = string
    stateless   = bool
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
      description = "Allow SSH from anywhere"
      protocol    = "6"
      source      = "0.0.0.0/0"
      stateless   = false
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
      description = "Allow WireGuard VPN"
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
      description = "Allow ICMP fragmentation needed"
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

variable "egress_security_rules" {
  description = "List of egress (outbound) security rules for the VCN security list. Default allows only HTTP, HTTPS, DNS, and NTP"
  type = list(object({
    description      = string
    protocol         = string
    destination      = string
    destination_type = string
    stateless        = bool
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
      description      = "Allow HTTPS outbound"
      protocol         = "6"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      stateless        = false
      tcp_options = {
        source_port_range = {
          min = 1
          max = 65535
        }
        min = 443
        max = 443
      }
      udp_options  = null
      icmp_options = null
    },
    {
      description      = "Allow HTTP outbound"
      protocol         = "6"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      stateless        = false
      tcp_options = {
        source_port_range = {
          min = 1
          max = 65535
        }
        min = 80
        max = 80
      }
      udp_options  = null
      icmp_options = null
    },
    {
      description      = "Allow DNS outbound (UDP)"
      protocol         = "17"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      stateless        = false
      tcp_options      = null
      udp_options = {
        source_port_range = {
          min = 1
          max = 65535
        }
        min = 53
        max = 53
      }
      icmp_options = null
    },
    {
      description      = "Allow DNS outbound (TCP)"
      protocol         = "6"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      stateless        = false
      tcp_options = {
        source_port_range = {
          min = 1
          max = 65535
        }
        min = 53
        max = 53
      }
      udp_options  = null
      icmp_options = null
    },
    {
      description      = "Allow NTP outbound"
      protocol         = "17"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      stateless        = false
      tcp_options      = null
      udp_options = {
        source_port_range = {
          min = 1
          max = 65535
        }
        min = 123
        max = 123
      }
      icmp_options = null
    }
  ]
}

variable "wireguard_client_configuration" {
  type        = string
  description = "WireGuard client configuration (wg0.conf content). If provided, WireGuard will be installed and configured automatically"
  default     = ""
  sensitive   = true
  validation {
    condition     = var.wireguard_client_configuration == "" || can(regex("^\\[Interface\\]", var.wireguard_client_configuration))
    error_message = "WireGuard configuration must start with [Interface] section or be empty."
  }
}
