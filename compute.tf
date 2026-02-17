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
      ADDITIONAL_SSH_PUB_KEY      = var.additional_ssh_public_key,
      INSTALL_RUNTIPI             = var.install_runtipi,
      RUNTIPI_REVERSE_PROXY_IP    = var.runtipi_reverse_proxy_ip,
      RUNTIPI_MAIN_NETWORK_SUBNET = var.runtipi_main_network_subnet,
      RUNTIPI_ADGUARD_IP          = var.runtipi_adguard_ip,
      INSTALL_COOLIFY             = var.install_coolify,
      COOLIFY_FQDN                = var.coolify_fqdn,
      COOLIFY_ADMIN_EMAIL         = var.coolify_admin_email,
      # SECURITY NOTE:
      # COOLIFY_ADMIN_PASSWORD is rendered into instance user_data via templatefile().
      # This value will be stored in plaintext in both Terraform state and OCI instance
      # metadata. Ensure that:
      #   - Access to Terraform state and OCI instance metadata is strictly controlled, and
      #   - The Coolify admin password is rotated from within Coolify immediately after
      #     first login / provisioning.
      # For stronger security, consider provisioning the admin password via OCI Vault or
      # another out-of-band mechanism instead of injecting it via user_data.
      COOLIFY_ADMIN_PASSWORD         = var.coolify_admin_password,
      COOLIFY_AUTO_UPDATE            = var.coolify_auto_update,
      WIREGUARD_CLIENT_CONFIGURATION = var.wireguard_client_configuration,
    }))
  }

  timeouts {
    create = "60m"
  }

  lifecycle {
    ignore_changes = [metadata["user_data"]]

    precondition {
      condition     = !(var.install_runtipi && var.install_coolify)
      error_message = "install_runtipi and install_coolify are mutually exclusive — both use ports 80/443."
    }

    precondition {
      condition     = (var.coolify_admin_email == "") == (var.coolify_admin_password == "")
      error_message = "coolify_admin_email and coolify_admin_password must both be set or both be empty."
    }
  }
}
