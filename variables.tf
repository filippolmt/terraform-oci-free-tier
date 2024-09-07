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
}

variable "additional_ssh_public_key" {
  type        = string
  description = "Additional public key to use for SSH access example: <<EOF > /home/ubuntu/.ssh/authorized_keys ssh-rsa AAAAB3NzaC1yc2EAA EOF"
  default     = ""
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
    # Oracle-provided image "Canonical-Ubuntu-22.04-Minimal-aarch64-2024.06.24-0"
    af-johannesburg-1 = "ocid1.image.oc1.af-johannesburg-1.aaaaaaaa7xnljvdm5kpk4m7zt7spaqyb3qjikwitnzpoebw7ggamy4exzv7a"
    ap-chuncheon-1    = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaaqlcsenyb566zfbppypis3wnpdi5wzgvh6ni4njx6ni3b54h2f46a"
    ap-hyderabad-1    = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaauqklehbg4utigurndarajxvpcrlokn7doqm2ctwplxqsni76wkza"
    ap-melbourne-1    = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaaxttpznd6kgln75wmdtalxmh374dc7vryk6ogxy4odv7ah5oh4coa"
    ap-mumbai-1       = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaaroeqq2dbas6jtuyszivuul4z2kec2fytvefcx4yn6nmxo2dmgo5a"
    ap-osaka-1        = "ocid1.image.oc1.ap-osaka-1.aaaaaaaaslgmmzf52mm5i6fnyeudflxyfpdopd34vezjngyac7r4k4zvsxza"
    ap-seoul-1        = "ocid1.image.oc1.ap-seoul-1.aaaaaaaamflo2tuozxfqsfe2ouyldnliqzzbzdnjgixjchsyl36zhz6ued5q"
    ap-singapore-1    = "ocid1.image.oc1.ap-singapore-1.aaaaaaaazmtpusw5a62d2ohooa4q3nu3atfpv2hrldek72d3l5ikmghardsq"
    ap-sydney-1       = "ocid1.image.oc1.ap-sydney-1.aaaaaaaaerkvnleaqrw5ugplx3k2el5l4pz4rr3exfbjna6ryj5fylocmnma"
    ap-tokyo-1        = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaal3hqdorzbtai6mc4bwggjshnog7u4i3xj7jz3v4xtimlmmkqy7ya"
    ca-montreal-1     = "ocid1.image.oc1.ca-montreal-1.aaaaaaaaun5fmmveoxeebsdnbs3dp3llsfmf3ol657aa7d3bshvnacxa45eq"
    ca-toronto-1      = "ocid1.image.oc1.ca-toronto-1.aaaaaaaauzynkrnddymm7346qpdzemhwqfigibq655ufdywbewpv2n4kmhtq"
    eu-amsterdam-1    = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaal3y4fa7lj6deamse4m4ukkznfeoywb5h6r2y6qdwdqynh2rkx5tq"
    eu-frankfurt-1    = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaylcz7y7w6uolelzd6ruexuqkufkqqgg2nrr6xnvhtukysuolzv4q"
    eu-madrid-1       = "ocid1.image.oc1.eu-madrid-1.aaaaaaaaw7wlmoprvzhu5ogyw6zjgdkclgyjidubfh2kzi27ns5tsl4agwcq"
    eu-marseille-1    = "ocid1.image.oc1.eu-marseille-1.aaaaaaaao7fvqbnna7orz4xnnpv3vlitdnnmesnz4gk5pzgvfcxgmadmoc4q"
    eu-milan-1        = "ocid1.image.oc1.eu-milan-1.aaaaaaaafofjducrv2pz7kj7thpbty2hyv37dtxce3x6cp5rwf2cngi7flva"
    eu-paris-1        = "ocid1.image.oc1.eu-paris-1.aaaaaaaaqnoet4akmzpatmorbqio4srukhrd434xh6kg37jp6f4hdlt5mbiq"
    eu-stockholm-1    = "ocid1.image.oc1.eu-stockholm-1.aaaaaaaavni5omi3qljq5umzlymbzxdczn3cmvgnfwb4tdfsls6qyehlv43q"
    eu-zurich-1       = "ocid1.image.oc1.eu-zurich-1.aaaaaaaaswipxdoxr6pwu2mjk6lff5r4prkmuhufucw5kjaf7446ksx37d7q"
    il-jerusalem-1    = "ocid1.image.oc1.il-jerusalem-1.aaaaaaaadzptbcjtrf7tx5sejgc7onb47u5ckrvakivyk6d2lueukm4uumsq"
    me-abudhabi-1     = "ocid1.image.oc1.me-abudhabi-1.aaaaaaaaocrezb6kjxfj6ksp6xqpq2rvdxujxfk7sjrvcyjtavjs4eyzy4na"
    me-dubai-1        = "ocid1.image.oc1.me-dubai-1.aaaaaaaaiiykp2iuznxgzrcrm2ln6o5nhfpfwuzlmwkvnmwgrzv747wfhowq"
    me-jeddah-1       = "ocid1.image.oc1.me-jeddah-1.aaaaaaaaaicrqlmq7qfk7gh2dnw5ett3z5qqwzof7kzt7mwij6fmwzqhi22a"
    mx-monterrey-1    = "ocid1.image.oc1.mx-monterrey-1.aaaaaaaaxqkk6akz7d2d356dk742kxq53kkfemewtlun6gj5jceeaddu2tkq"
    mx-queretaro-1    = "ocid1.image.oc1.mx-queretaro-1.aaaaaaaakty7iicnprrzzdv7mr5onnbigbq6i4vaudobx3x6ya34uryrrmqa"
    sa-bogota-1       = "ocid1.image.oc1.sa-bogota-1.aaaaaaaagpfqtybbtm5pikjd6qivrjd6d7p7y556rystirdayle6n3nxdzoa"
    sa-santiago-1     = "ocid1.image.oc1.sa-santiago-1.aaaaaaaan4ex5fu662bmizpkpu3vxalty7j6waowogwmebiyijhiomin2yja"
    sa-saopaulo-1     = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaaeor33zqzryd3smqgyg2arr4whsuobbtlwzxazovoto5vjnckaacq"
    sa-valparaiso-1   = "ocid1.image.oc1.sa-valparaiso-1.aaaaaaaafj5y2dbizrqlr44ytyxukkejp3heuork3whgdec7h5sw3ckw7whq"
    sa-vinhedo-1      = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaahwildebomq43h7xaufnbkgx6n2qvn5kihndcvkzmjy3vhwaqx5ka"
    uk-cardiff-1      = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaak55bg7dku2z3smbb3nczyj6jwmhlashfazcc3iemqmbwyjthic5a"
    uk-london-1       = "ocid1.image.oc1.uk-london-1.aaaaaaaantzj7ujtr5wcojxtgc76oveoq5xcz7egczd56x67wivib3hfak3q"
    us-ashburn-1      = "ocid1.image.oc1.iad.aaaaaaaai42i6avvfxqawj3bjl5uzhlyq5lqkqhbeg4lpo5corvwqgnvrloq"
    us-chicago-1      = "ocid1.image.oc1.us-chicago-1.aaaaaaaazcw4u4fboyq5t33t7dj3jbwqvgy4jbkgxfmtxs2xxdnczshdhusa"
    us-phoenix-1      = "ocid1.image.oc1.phx.aaaaaaaativnqm7keyzvvmetzp5cxlavfk5xyylt6w2epbjjjwmkv6xijnbq"
    us-sanjose-1      = "ocid1.image.oc1.us-sanjose-1.aaaaaaaaouu2iwsejzxx3mqrczvmcx3az4jcnztjoysn3whf2oxamob22jqq"
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
