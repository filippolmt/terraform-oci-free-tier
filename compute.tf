data "oci_identity_availability_domain" "ad" {
  compartment_id = var.compartment_ocid
  ad_number      = var.availability_domain_number
}

data "oci_core_private_ips" "instance_private_ip" {
  ip_address = oci_core_instance.instance.private_ip
  subnet_id  = oci_core_subnet.subnet.id
}

resource "oci_core_public_ip" "public_ip" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.instance_display_name} PublicIP"
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.instance_private_ip.private_ips[0]["id"]
  freeform_tags  = var.freeform_tags
}

resource "oci_core_instance" "instance" {
  availability_domain                 = data.oci_identity_availability_domain.ad.name
  compartment_id                      = var.compartment_ocid
  display_name                        = var.instance_display_name
  shape                               = var.instance_shape
  fault_domain                        = var.fault_domain
  freeform_tags                       = var.freeform_tags
  is_pv_encryption_in_transit_enabled = true

  availability_config {
    is_live_migration_preferred = true
    recovery_action             = "RESTORE_INSTANCE"
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet.id
    display_name     = "VNIC"
    assign_public_ip = false
    hostname_label   = var.instance_display_name
  }

  instance_options {
    are_legacy_imds_endpoints_disabled = true
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

  lifecycle {
    ignore_changes = [metadata["user_data"]]
  }
}
