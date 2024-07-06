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
  type        = map(any)
  description = "The OCID of the image to use for the instance"
  default = {
    # See https://docs.oracle.com/en-us/iaas/images/image/d6c24c39-00c1-4ba9-bc0e-b4acf4a6c560/
    # Oracle-provided image "Canonical-Ubuntu-22.04-Minimal-aarch64-2024.03.18-0"
    af-johannesburg-1 = "ocid1.image.oc1.af-johannesburg-1.aaaaaaaax333o2ycfo3kez6e2lcw5twqdrkfqrumo6hs3iwhdf27gnnbrx5a"
    ap-chuncheon-1    = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaac45fgllwh5rdl2chkf6xte2yjvqbtlaz7zkhrxs2pcmnlzjbfs5a"
    ap-hyderabad-1    = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaapmowuredsvjoajp2hxhrxxvk4zx6wlpoedptn2vn4jc67i4yzqqq"
    ap-melbourne-1    = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaa5ottxpbcv44udrgaivtibl2kclq267g347mhkmxf7sukwe6rlowa"
    ap-mumbai-1       = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaaq3emfywi6i7oyi5bzd4o2p4wqw3gq6l4r4wj5qd3azsicfq33iea"
    ap-osaka-1        = "ocid1.image.oc1.ap-osaka-1.aaaaaaaalkf7sczol3b2u3e4g365cb44vh2hlwv4y45p4sumobi2nxbrftzq"
    ap-seoul-1        = "ocid1.image.oc1.ap-seoul-1.aaaaaaaazsuvtlhqoe67xqgeazq62ykipstgv5ct3i62zfzezxd4tpgcaq2q"
    ap-singapore-1    = "ocid1.image.oc1.ap-singapore-1.aaaaaaaapptlp7yb5s6regbd77w2qylyi6d7brnnt3qm5vlmutgiq5jxfb4q"
    ap-sydney-1       = "ocid1.image.oc1.ap-sydney-1.aaaaaaaazltimyhsp3vogaujtizcsyauvz3avzyqwdbf7l3jcujj76vzpcna"
    ap-tokyo-1        = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaahomava4u6ud4ztzysq3bnn6iktkyfvsthrvs4gjemkacfgpr53yq"
    ca-montreal-1     = "ocid1.image.oc1.ca-montreal-1.aaaaaaaa25pkd4hksfm4ryuvj7eendqoo4hel4flpe2lmhlgs3rkw34sam2q"
    ca-toronto-1      = "ocid1.image.oc1.ca-toronto-1.aaaaaaaafrhto7vi2lae4i5gki234znbj6i7iiodhychrxnmnzzkkscq45ua"
    eu-amsterdam-1    = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaamwi2yxo5mbwbxydz5it4talwzkzfknywqcxuopi3suu575eu2rja"
    eu-frankfurt-1    = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaapg6sk4uypeope6rsjdqgemtp7v4wu45din3eub47vfpwdjoymadq"
    eu-madrid-1       = "ocid1.image.oc1.eu-madrid-1.aaaaaaaaeoin77kq4jly4myzy7ap63iwmf6razdlftoyxvk7o2bcxnlyx56a"
    eu-marseille-1    = "ocid1.image.oc1.eu-marseille-1.aaaaaaaai5mwzo3turcncrh5zk2zbewqa7sn6fh26v74hosswed2zjuquj2q"
    eu-milan-1        = "ocid1.image.oc1.eu-milan-1.aaaaaaaasxksyjw24lp77uzemfqu2gtyledmksymjjom7m7d4koizg3goiza"
    eu-paris-1        = "ocid1.image.oc1.eu-paris-1.aaaaaaaagbmz6kz2it6ft64dgf7kvoevdy53soejx5ucudd5zwoifcavyh5q"
    eu-stockholm-1    = "ocid1.image.oc1.eu-stockholm-1.aaaaaaaast4rypafl2kho2g7nbqaec5tv3xdj4e5b6iuqdieurcionly2jna"
    eu-zurich-1       = "ocid1.image.oc1.eu-zurich-1.aaaaaaaajoochdylix7hfdf3e3kfsynhaztz5rtl3gacz6ke6ugw56icmuxa"
    il-jerusalem-1    = "ocid1.image.oc1.il-jerusalem-1.aaaaaaaaa2gspnrm6jdmxv4xqffjnvc5bu7xtmzptotcm2aygkvq3etwukkq"
    me-abudhabi-1     = "ocid1.image.oc1.me-abudhabi-1.aaaaaaaaghp5mezfrznk7yx5mfu5d75evrltrukaehkxzfmwlwn3vd47pxna"
    me-dubai-1        = "ocid1.image.oc1.me-dubai-1.aaaaaaaaxmqbxvp3tpa5rbp2swhfrmcbqok5vjhqhmqj6kmoy2c4j3olcgoq"
    me-jeddah-1       = "ocid1.image.oc1.me-jeddah-1.aaaaaaaa3o55xjoxggxzo3ufvzzyfpa26dx5fehernulxoctdir45hazyylq"
    mx-monterrey-1    = "ocid1.image.oc1.mx-monterrey-1.aaaaaaaaeasnsvrmjtnp2sa2emq2x63ixfdpq36mouj5qnz54x3yrsidiidq"
    mx-queretaro-1    = "ocid1.image.oc1.mx-queretaro-1.aaaaaaaawiewa5mlk7ty5ycfeqr77islx5ziiqm434kc35spf3ntazc6qahq"
    sa-bogota-1       = "ocid1.image.oc1.sa-bogota-1.aaaaaaaa4ogdfogwycxaxqhrngfd65rvahy4tcvjda2pgqggbfccjfpsvm6q"
    sa-santiago-1     = "ocid1.image.oc1.sa-santiago-1.aaaaaaaanrhvodnakgpu7f44w6oytaltc7x6pn6zirgri3ckyubcemlhpmxq"
    sa-saopaulo-1     = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaax4w5f5dsgxbsnu2c6iuf6wbwtfekrisjrzb6a77nlun75ap33vbq"
    sa-valparaiso-1   = "ocid1.image.oc1.sa-valparaiso-1.aaaaaaaauwwidibcvn4kts3qmhy4qqxjuaa32fanvqlziv2vc2zyeaw4gmva"
    sa-vinhedo-1      = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaalcyxi2by47atkj5pgmiwe3yiq4fe62i3nyhuqchgwmdtrfnxnhba"
    uk-cardiff-1      = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaalkuehgqztca5mog32zcnhfnwx4xyn5pymvtcog2xbpcqfppdxxfa"
    uk-london-1       = "ocid1.image.oc1.uk-london-1.aaaaaaaadoqxyuecpc7z2oilbsorxypr4ssvkrvcsqnyoo5lciiel66wpsca"
    us-ashburn-1      = "ocid1.image.oc1.iad.aaaaaaaagxazxgs5mz5xglwm5i7a7pdphiu7f3h2u6njatz6akisfxdgjmwq"
    us-chicago-1      = "ocid1.image.oc1.us-chicago-1.aaaaaaaazn6piezti3khlsminniokag5cs7jiu3csqdiib3ex2jqv76qx3cq"
    us-phoenix-1      = "ocid1.image.oc1.phx.aaaaaaaafuu7f34bb6gzgbkif6nz5vhibhop4zugjjma723uhc562mplgfza"
    us-sanjose-1      = "ocid1.image.oc1.us-sanjose-1.aaaaaaaaapli23rbdkhfdejmayyckf7kfelei5ofn54jiunf7tcvpfsl4nuq"
  }
}

variable "security_list_rules" {
  description = "The security list rules"
  type        = list(object({
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
      udp_options = {
        source_port_range = {
          min = null
          max = null
        }
        min = null
        max = null
      }
      icmp_options = {
        type = null
        code = null
      }
    },
    {
      protocol  = "17"
      source    = "0.0.0.0/0"
      stateless = false
      tcp_options = {
        source_port_range = {
          min = null
          max = null
        }
        min = null
        max = null
      }
      udp_options = {
        source_port_range = {
          min = 1
          max = 65535
        }
        min = 51820
        max = 51820
      }
      icmp_options = {
        type = null
        code = null
      }
    },
    {
      protocol  = "1"
      source    = "0.0.0.0/0"
      stateless = false
      tcp_options = {
        source_port_range = {
          min = null
          max = null
        }
        min = null
        max = null
      }
      udp_options = {
        source_port_range = {
          min = null
          max = null
        }
        min = null
        max = null
      }
      icmp_options = {
        type = 3
        code = 4
      }
    }
  ]
}