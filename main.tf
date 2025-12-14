resource "oci_core_vcn" "vcn" {
  cidr_block     = var.vcn_cidr_block
  compartment_id = var.compartment_ocid
  display_name   = "VCN"
  dns_label      = "VCN"
  freeform_tags  = var.freeform_tags
}

resource "oci_core_subnet" "subnet" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  cidr_block          = var.subnet_cidr_block
  display_name        = "Subnet"
  dns_label           = "Subnet"
  security_list_ids   = [oci_core_security_list.security_list.id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.vcn.id
  route_table_id      = oci_core_vcn.vcn.default_route_table_id
  dhcp_options_id     = oci_core_vcn.vcn.default_dhcp_options_id
  freeform_tags       = var.freeform_tags
}

resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "IG"
  vcn_id         = oci_core_vcn.vcn.id
  freeform_tags  = var.freeform_tags
}

resource "oci_core_default_route_table" "default_route_table" {
  manage_default_resource_id = oci_core_vcn.vcn.default_route_table_id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

resource "oci_core_security_list" "security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "Security List"
  freeform_tags  = var.freeform_tags

  dynamic "ingress_security_rules" {
    for_each = var.ingress_security_rules
    content {
      description = ingress_security_rules.value.description
      protocol    = ingress_security_rules.value.protocol
      source      = ingress_security_rules.value.source
      stateless   = ingress_security_rules.value.stateless

      dynamic "tcp_options" {
        for_each = ingress_security_rules.value.protocol == "6" ? [ingress_security_rules.value.tcp_options] : []
        content {
          source_port_range {
            min = tcp_options.value.source_port_range.min
            max = tcp_options.value.source_port_range.max
          }

          min = tcp_options.value.min
          max = tcp_options.value.max
        }
      }

      dynamic "udp_options" {
        for_each = ingress_security_rules.value.protocol == "17" ? [ingress_security_rules.value.udp_options] : []
        content {
          source_port_range {
            min = udp_options.value.source_port_range.min
            max = udp_options.value.source_port_range.max
          }

          min = udp_options.value.min
          max = udp_options.value.max
        }
      }

      dynamic "icmp_options" {
        for_each = ingress_security_rules.value.protocol == "1" ? [ingress_security_rules.value.icmp_options] : []
        content {
          type = icmp_options.value.type
          code = icmp_options.value.code
        }
      }
    }
  }

  dynamic "egress_security_rules" {
    for_each = var.egress_security_rules
    content {
      description      = egress_security_rules.value.description
      protocol         = egress_security_rules.value.protocol
      destination      = egress_security_rules.value.destination
      destination_type = egress_security_rules.value.destination_type
      stateless        = egress_security_rules.value.stateless

      dynamic "tcp_options" {
        for_each = egress_security_rules.value.protocol == "6" ? [egress_security_rules.value.tcp_options] : []
        content {
          source_port_range {
            min = tcp_options.value.source_port_range.min
            max = tcp_options.value.source_port_range.max
          }

          min = tcp_options.value.min
          max = tcp_options.value.max
        }
      }

      dynamic "udp_options" {
        for_each = egress_security_rules.value.protocol == "17" ? [egress_security_rules.value.udp_options] : []
        content {
          source_port_range {
            min = udp_options.value.source_port_range.min
            max = udp_options.value.source_port_range.max
          }

          min = udp_options.value.min
          max = udp_options.value.max
        }
      }

      dynamic "icmp_options" {
        for_each = egress_security_rules.value.protocol == "1" ? [egress_security_rules.value.icmp_options] : []
        content {
          type = icmp_options.value.type
          code = icmp_options.value.code
        }
      }
    }
  }
}

resource "oci_core_public_ip" "public_ip" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.instance_display_name} PublicIP"
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.instance_private_ip.private_ips[0]["id"]
  freeform_tags  = var.freeform_tags
}

data "oci_core_private_ips" "instance_private_ip" {
  ip_address = oci_core_instance.instance.private_ip
  subnet_id  = oci_core_subnet.subnet.id
}

resource "oci_core_instance" "instance" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = var.instance_display_name
  shape               = var.instance_shape
  fault_domain        = var.fault_domain
  freeform_tags       = var.freeform_tags

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet.id
    display_name     = "VNIC"
    assign_public_ip = false
    hostname_label   = var.instance_display_name
  }

  shape_config {
    memory_in_gbs = var.instance_shape_config_memory_gb
    ocpus         = var.instance_shape_config_ocpus
  }

  source_details {
    source_type             = "image"
    source_id               = var.instance_image_ocids_by_region[var.region]
    boot_volume_size_in_gbs = var.instance_shape_boot_volume_size_gb
    kms_key_id              = var.kms_key_id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(templatefile("${path.module}/scripts/startup.sh", {
      ADDITIONAL_SSH_PUB_KEY         = var.additional_ssh_public_key,
      INSTALL_RUNTIPI                = var.install_runtipi,
      RUNTIPI_REVERSE_PROXY_IP       = var.runtipi_reverse_proxy_ip,
      RUNTIPI_MAIN_NETWORK_SUBNET    = var.runtipi_main_network_subnet,
      RUNTIPI_ADGUARD_IP             = var.runtipi_adguard_ip,
      WIREGUARD_CLIENT_CONFIGURATION = var.wireguard_client_configuration,
    }))
  }

  timeouts {
    create = "60m"
  }
}

resource "oci_core_volume" "docker_volume" {
  display_name        = "DockerVolume"
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domain.ad.name
  size_in_gbs         = var.docker_volume_size_gb
  kms_key_id          = var.kms_key_id
  freeform_tags       = var.freeform_tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "oci_core_volume_attachment" "docker_volume_attachment" {
  display_name    = "DockerVolumeAttachment"
  instance_id     = oci_core_instance.instance.id
  volume_id       = oci_core_volume.docker_volume.id
  attachment_type = "paravirtualized"
}

resource "oci_core_volume_backup_policy" "docker_volume_backup_policy" {
  display_name   = "DockerVolumeBackupPolicy"
  compartment_id = var.compartment_ocid
  freeform_tags  = var.freeform_tags

  schedules {
    backup_type       = "INCREMENTAL"
    period            = "ONE_DAY"
    hour_of_day       = "1"
    offset_type       = "STRUCTURED"
    retention_seconds = 432000
    time_zone         = "REGIONAL_DATA_CENTER_TIME"
  }
}

resource "oci_core_volume_backup_policy_assignment" "docker_volume_backup_policy_assignment" {
  asset_id  = oci_core_volume.docker_volume.id
  policy_id = oci_core_volume_backup_policy.docker_volume_backup_policy.id
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.compartment_ocid
  ad_number      = var.availability_domain_number
}

