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

  validation {
    condition     = can(cidrnetmask(var.vcn_cidr_block))
    error_message = "Must be valid CIDR notation."
  }
}

variable "subnet_cidr_block" {
  type        = string
  description = "The CIDR block for the subnet"
  default     = "10.1.0.0/24"

  validation {
    condition     = can(cidrnetmask(var.subnet_cidr_block))
    error_message = "Must be valid CIDR notation."
  }
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

  validation {
    condition     = var.availability_domain_number >= 1 && var.availability_domain_number <= 3
    error_message = "Must be 1, 2, or 3."
  }
}

variable "fault_domain" {
  type        = string
  description = "The fault domain for the instance (FAULT-DOMAIN-1, FAULT-DOMAIN-2, or FAULT-DOMAIN-3)"
  default     = "FAULT-DOMAIN-2"

  validation {
    condition     = can(regex("^FAULT-DOMAIN-[1-3]$", var.fault_domain))
    error_message = "Must be FAULT-DOMAIN-1, FAULT-DOMAIN-2, or FAULT-DOMAIN-3."
  }
}

variable "instance_shape" {
  type        = string
  description = "The OCI compute shape (VM.Standard.A1.Flex for Free Tier ARM instances)"
  default     = "VM.Standard.A1.Flex"
}

variable "instance_shape_config_memory_gb" {
  type        = number
  description = "The amount of memory in GBs for the instance"
  default     = 24

  validation {
    condition     = var.instance_shape_config_memory_gb >= 1 && var.instance_shape_config_memory_gb <= 24
    error_message = "Free Tier: max 24GB RAM for VM.Standard.A1.Flex."
  }
}

variable "instance_shape_config_ocpus" {
  type        = number
  description = "The number of OCPUs for the instance"
  default     = 4

  validation {
    condition     = var.instance_shape_config_ocpus >= 1 && var.instance_shape_config_ocpus <= 4
    error_message = "Free Tier: max 4 OCPUs for VM.Standard.A1.Flex."
  }
}

variable "instance_shape_boot_volume_size_gb" {
  type        = number
  description = "The size of the boot volume in GBs"
  default     = 50

  validation {
    condition     = var.instance_shape_boot_volume_size_gb >= 50
    error_message = "Boot volume minimum is 50GB."
  }
}

variable "docker_volume_size_gb" {
  type        = number
  description = "The size of the secondary block volume in GBs (mounted at /mnt/data for Docker data)"
  default     = 150

  validation {
    condition     = var.docker_volume_size_gb >= 50
    error_message = "Block volume minimum is 50GB."
  }
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
    # Canonical Ubuntu 24.04 Minimal for ARM64: https://docs.oracle.com/en-us/iaas/images/ubuntu-2404/canonical-ubuntu-24-04-minimal-aarch64-2025-10-31-0.htm

    af-johannesburg-1 = "ocid1.image.oc1.af-johannesburg-1.aaaaaaaac74zk4rm447grg5rmu6ex2xj2sipgue2y26jpvquwxyfw6g2xowq"
    ap-chuncheon-1    = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaaa3cuoai5lfap4e2w3l5jk5262rvafl7dpwlistkkntexiu5h25bq"
    ap-hyderabad-1    = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaaxxuf3ebmgzy32bzlfjhbyr4vpn3rqtqodi5c24kwjojosea6zzbq"
    ap-melbourne-1    = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaameaiob3abo7nzzg4hb2kmwi5ihqmkpbwt2hax65szewv52rt3z6a"
    ap-mumbai-1       = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaacm56ci4xs3fqx7zsrxvedeqplrlp6gxy6lnga4qi62wywssusmkq"
    ap-osaka-1        = "ocid1.image.oc1.ap-osaka-1.aaaaaaaawzfbc5pjimseh6eisfqhfztalzx46h5bhntvxomckmulk7hqtyoa"
    ap-seoul-1        = "ocid1.image.oc1.ap-seoul-1.aaaaaaaay3tcv6ttdutmyu32prvdidg5lojd2lzhue4eqnycor5oofiodeyq"
    ap-singapore-1    = "ocid1.image.oc1.ap-singapore-1.aaaaaaaamhhpqoyiobauojy3m2huj6tusesizrggbpek2wo4tksiwwv43ihq"
    ap-sydney-1       = "ocid1.image.oc1.ap-sydney-1.aaaaaaaahbktlxr6owykyfvduw5b24giid5stnncevl2nif6pdcgtscd5h5q"
    ap-tokyo-1        = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaaj7gohm3adsdbhhn7emx7bd6jny7dj5mipwnq62ub6eeryjgr7gnq"
    ca-montreal-1     = "ocid1.image.oc1.ca-montreal-1.aaaaaaaacezsnh42klz6sd5hlqsrlmypeqk4hxo3xphii4qa2l2gw2lkkm7a"
    ca-toronto-1      = "ocid1.image.oc1.ca-toronto-1.aaaaaaaaypprlzb5aftk77ltpwspqtvdk2bbtsxiknqycci2kxznfcuihfsa"
    eu-amsterdam-1    = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaaadazle32svd6dhz4ano5iqxh22bqoy3c6gaodvhg7x7iaq23yxnq"
    eu-frankfurt-1    = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaajzudgoto32j5q245xjkm2p7nj6rrza2bb5yyqjgm56k4ib2to6sq"
    eu-madrid-1       = "ocid1.image.oc1.eu-madrid-1.aaaaaaaawo47bihidpyebw2zlaptpbmeqx7zsww6bllr4uybttrblcmtmvjq"
    eu-marseille-1    = "ocid1.image.oc1.eu-marseille-1.aaaaaaaa3334ijm2zwbgmkqrrbkh2ecyekudopjkcndrrw5nhbeoyk66kiqa"
    eu-milan-1        = "ocid1.image.oc1.eu-milan-1.aaaaaaaae3hiyvu2hdfblxr4xp2tpvbiow7nvpner6ekvysc5whmzyaqjoqa"
    eu-paris-1        = "ocid1.image.oc1.eu-paris-1.aaaaaaaaeagkmkwv5cl7x2f2ylekvqxlnnlkahuepxmck7yawdkjmg6e5ypq"
    eu-stockholm-1    = "ocid1.image.oc1.eu-stockholm-1.aaaaaaaad5qwbyuemyoa2hrngbb4iydmb5nfcfn3s3jki7qqhlmkomoscv6q"
    eu-zurich-1       = "ocid1.image.oc1.eu-zurich-1.aaaaaaaas6gvo5dqyqpisatcs56my2ldwc4xc57lydfrzfbuutnhjceapdqq"
    il-jerusalem-1    = "ocid1.image.oc1.il-jerusalem-1.aaaaaaaac5e6i6ztlu7ksbn6qujaaqlgpr7xdpcryms3fviq6kpn26p3jhaa"
    me-abudhabi-1     = "ocid1.image.oc1.me-abudhabi-1.aaaaaaaay4xdwt2tzpsqkifdxciuvbvfqwdij2btal7w2gucdguux6vs2iia"
    me-dubai-1        = "ocid1.image.oc1.me-dubai-1.aaaaaaaalu3waogupaq2b2kvi4ny6uxuvjdbdfvgchpk7toinrn7ei6l7toq"
    me-jeddah-1       = "ocid1.image.oc1.me-jeddah-1.aaaaaaaarqfbmwhhapsjv6ncotol2haolzsjg4bkqxngn7cjtdshohee575a"
    mx-monterrey-1    = "ocid1.image.oc1.mx-monterrey-1.aaaaaaaayjefqnzikropxrizlxkdqlu4e4n7mallxolsur2ua2szyoczicza"
    mx-queretaro-1    = "ocid1.image.oc1.mx-queretaro-1.aaaaaaaalob3n6p7hb2c7cabvax6cmzzcrxxl2cexakvytmhfi4vopusjwyq"
    sa-bogota-1       = "ocid1.image.oc1.sa-bogota-1.aaaaaaaac5aytlzu6lk5s6n7frapmvg5xgkpdmc7fci6b56urie54ea46paa"
    sa-santiago-1     = "ocid1.image.oc1.sa-santiago-1.aaaaaaaaeyf2gv5wo5mzsijd3zparivuzwexxaovx3fes3b4am6qn4vjkwrq"
    sa-saopaulo-1     = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaayiprqwic72dwa6teukf4uyd2vqntqvm4cddvvvjcttsn7zn6jsza"
    sa-valparaiso-1   = "ocid1.image.oc1.sa-valparaiso-1.aaaaaaaau4tjiejqqzfdbelzskgjvbkuc4n3rmwwylzuk3oon3l32ee5ydja"
    sa-vinhedo-1      = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaahqhs7fl5b2eoarmbv2hibeum4qp6xf7bpuvndsxbwxow2g66xxka"
    uk-cardiff-1      = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaa3tw6w7xa3crrtumyidagfy5sfffm5ulf5wk4n4enq56cfgv3r7pq"
    uk-london-1       = "ocid1.image.oc1.uk-london-1.aaaaaaaahfrghsffkvpikumb7v42bsxlk23medjry234dcspckdnbifbsocq"
    us-ashburn-1      = "ocid1.image.oc1.iad.aaaaaaaaowocjhlbitbc5la6hvimvhi7iseebfzj2honlkyjgqdpuy5syxea"
    us-chicago-1      = "ocid1.image.oc1.us-chicago-1.aaaaaaaa7kpyzoekvmsyvvwutgbnjv2cb4heft7fotyaplsuacdidgxnodwa"
    us-phoenix-1      = "ocid1.image.oc1.phx.aaaaaaaasw7zpqcko4iqizjsnco6e4md6sxmiimdaedzzbb2appwvqn4uyma"
    us-sanjose-1      = "ocid1.image.oc1.us-sanjose-1.aaaaaaaakvkyx6huyxk7vikyswxdcpxt74ix3nwgsbozoxikyoawetjyq7ta"
  }
}

variable "enable_ping" {
  type        = bool
  description = "Whether to allow ICMP echo requests (ping) from anywhere"
  default     = false
}

variable "custom_ingress_security_rules" {
  description = "Additional custom ingress rules. SSH (22/TCP) and ICMP fragmentation are always enabled. HTTP (80), HTTPS (443), and WireGuard (51820/UDP) are auto-added when install_runtipi=true. Ping is controlled by enable_ping."
  type = list(object({
    description = optional(string, "Custom rule")
    protocol    = string # "6" (TCP) or "17" (UDP)
    source      = optional(string, "0.0.0.0/0")
    port_min    = number
    port_max    = number
  }))
  default = []

  validation {
    condition     = alltrue([for r in var.custom_ingress_security_rules : contains(["6", "17"], r.protocol)])
    error_message = "Protocol must be \"6\" (TCP) or \"17\" (UDP)."
  }

  validation {
    condition     = alltrue([for r in var.custom_ingress_security_rules : r.port_min >= 1 && r.port_min <= 65535 && r.port_max >= 1 && r.port_max <= 65535])
    error_message = "Ports must be between 1 and 65535."
  }

  validation {
    condition     = alltrue([for r in var.custom_ingress_security_rules : r.port_min <= r.port_max])
    error_message = "port_min must be less than or equal to port_max."
  }
}

variable "egress_security_rules" {
  description = "List of egress (outbound) security rules for the VCN security list. Default allows only HTTP, HTTPS, DNS, and NTP"
  type = list(object({
    description      = string
    protocol         = string
    destination      = string
    destination_type = string
    stateless        = bool
    tcp_options = optional(object({
      min = number
      max = number
    }))
    udp_options = optional(object({
      min = number
      max = number
    }))
    icmp_options = optional(object({
      type = number
      code = number
    }))
  }))
  default = [
    {
      description      = "Allow HTTPS outbound"
      protocol         = "6"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      stateless        = false
      tcp_options      = { min = 443, max = 443 }
    },
    {
      description      = "Allow HTTP outbound"
      protocol         = "6"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      stateless        = false
      tcp_options      = { min = 80, max = 80 }
    },
    {
      description      = "Allow DNS outbound (UDP)"
      protocol         = "17"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      stateless        = false
      udp_options      = { min = 53, max = 53 }
    },
    {
      description      = "Allow DNS outbound (TCP)"
      protocol         = "6"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      stateless        = false
      tcp_options      = { min = 53, max = 53 }
    },
    {
      description      = "Allow NTP outbound"
      protocol         = "17"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      stateless        = false
      udp_options      = { min = 123, max = 123 }
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
