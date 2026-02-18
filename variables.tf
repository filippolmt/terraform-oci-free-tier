variable "oracle_api_key_fingerprint" {
  type        = string
  description = "The fingerprint of the OCI API public key"
  nullable    = false
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
  nullable    = false
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

  validation {
    condition = contains([
      "af-johannesburg-1", "ap-chuncheon-1", "ap-hyderabad-1", "ap-melbourne-1",
      "ap-mumbai-1", "ap-osaka-1", "ap-seoul-1", "ap-singapore-1", "ap-sydney-1",
      "ap-tokyo-1", "ca-montreal-1", "ca-toronto-1", "eu-amsterdam-1", "eu-frankfurt-1",
      "eu-madrid-1", "eu-marseille-1", "eu-milan-1", "eu-paris-1", "eu-stockholm-1",
      "eu-zurich-1", "il-jerusalem-1", "me-abudhabi-1", "me-dubai-1", "me-jeddah-1",
      "mx-monterrey-1", "mx-queretaro-1", "sa-bogota-1", "sa-santiago-1", "sa-saopaulo-1",
      "sa-valparaiso-1", "sa-vinhedo-1", "uk-cardiff-1", "uk-london-1", "us-ashburn-1",
      "us-chicago-1", "us-phoenix-1", "us-sanjose-1",
    ], var.region)
    error_message = "Region not supported. Must match an entry in instance_image_ocids_by_region."
  }
}

variable "instance_display_name" {
  type        = string
  description = "The display name of the instance (also used as hostname label — alphanumeric and hyphens only, must start with a letter)"
  default     = "DockerHost"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{0,62}$", var.instance_display_name))
    error_message = "Must start with a letter, contain only letters, digits, and hyphens, and be at most 63 characters (OCI hostname label constraints)."
  }
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
  description = "The CIDR block for the subnet (must be within vcn_cidr_block; OCI will reject it at apply time otherwise)"
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
  description = "Whether to install RunTipi homeserver (https://runtipi.io). Mutually exclusive with install_coolify."
  default     = true
}

variable "install_coolify" {
  type        = bool
  description = "Whether to install Coolify self-hosted PaaS (https://coolify.io). Mutually exclusive with install_runtipi."
  default     = false
}



variable "coolify_admin_email" {
  type        = string
  description = "Email for the Coolify admin account. Must be set together with coolify_admin_password. If empty, account is created via web UI on first access."
  default     = ""

  validation {
    condition     = var.coolify_admin_email == "" || can(regex("^[^@]+@[^@]+\\.[^@]+$", var.coolify_admin_email))
    error_message = "Must be a valid email address or empty."
  }
}

variable "coolify_admin_password" {
  type        = string
  description = "Password for the Coolify admin account. Must be set together with coolify_admin_email. If empty, account is created via web UI on first access. Note: this value is embedded in cloud-init user_data (visible in instance metadata) and Terraform state — rotate after first login."
  default     = ""
  sensitive   = true

  validation {
    condition     = var.coolify_admin_password == "" || length(var.coolify_admin_password) >= 8
    error_message = "Must be at least 8 characters or empty."
  }
}

variable "coolify_auto_update" {
  type        = bool
  description = "Whether to enable automatic updates for Coolify"
  default     = true
}

variable "coolify_admin_source_cidr" {
  type        = string
  description = "Source CIDR allowed for Coolify admin ports (8000 UI, 6001-6002 real-time). HTTP/HTTPS (80, 443) for deployed apps remain open to all. Default: 0.0.0.0/0 — all IPs."
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrhost(var.coolify_admin_source_cidr, 0))
    error_message = "Must be valid CIDR notation (e.g. 0.0.0.0/0 or 203.0.113.0/24)."
  }
}


variable "runtipi_main_network_subnet" {
  type        = string
  description = "The Docker network subnet for RunTipi containers"
  default     = "172.18.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.runtipi_main_network_subnet))
    error_message = "Must be valid CIDR notation (e.g. 172.18.0.0/16)."
  }
}

variable "runtipi_reverse_proxy_ip" {
  type        = string
  description = "The static IP for RunTipi reverse proxy (Traefik). Must be within runtipi_main_network_subnet"
  default     = "172.18.0.254"

  validation {
    condition     = can(regex("^(\\d{1,3}\\.){3}\\d{1,3}$", var.runtipi_reverse_proxy_ip))
    error_message = "Must be a valid IPv4 address (e.g. 172.18.0.254)."
  }
}

variable "runtipi_adguard_ip" {
  type        = string
  description = "The static IP for AdGuard. Must be within runtipi_main_network_subnet and different from reverse proxy IP"
  default     = "172.18.0.253"

  validation {
    condition     = can(regex("^(\\d{1,3}\\.){3}\\d{1,3}$", var.runtipi_adguard_ip))
    error_message = "Must be a valid IPv4 address (e.g. 172.18.0.253)."
  }
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

variable "ssh_source_cidr" {
  type        = string
  description = "Source CIDR allowed for SSH access (default: 0.0.0.0/0 — all IPs)"
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrhost(var.ssh_source_cidr, 0))
    error_message = "Must be valid CIDR notation (e.g. 0.0.0.0/0 or 203.0.113.0/24)."
  }
}

variable "enable_ping" {
  type        = bool
  description = "Whether to allow ICMP echo requests (ping) from anywhere"
  default     = false
}

variable "custom_ingress_security_rules" {
  description = "Additional custom ingress rules. SSH (22/TCP) and ICMP fragmentation are always enabled. HTTP (80), HTTPS (443), and WireGuard (51820/UDP) are auto-added when install_runtipi=true. HTTP (80), HTTPS (443), Coolify UI (8000), and real-time (6001-6002) are auto-added when install_coolify=true. Ping is controlled by enable_ping."
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

  validation {
    condition     = alltrue([for r in var.custom_ingress_security_rules : can(cidrhost(r.source, 0))])
    error_message = "Each custom ingress rule 'source' must be a valid CIDR (e.g. 0.0.0.0/0)."
  }
}

variable "enable_unrestricted_egress" {
  type        = bool
  description = "Allow all outbound traffic (all protocols, all ports, 0.0.0.0/0). When false, only egress_security_rules are applied. NOTE: if using WireGuard with restrictive egress, add a UDP rule for your WireGuard server endpoint port to egress_security_rules."
  default     = true
}

variable "egress_security_rules" {
  description = "List of egress (outbound) security rules. Only used when enable_unrestricted_egress=false. Default allows HTTP, HTTPS, DNS, and NTP."
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
