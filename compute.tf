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
      TIMEZONE                       = var.timezone,
      INSTALL_RUNTIPI                = var.install_runtipi,
      RUNTIPI_REVERSE_PROXY_IP       = var.runtipi_reverse_proxy_ip,
      RUNTIPI_MAIN_NETWORK_SUBNET    = var.runtipi_main_network_subnet,
      RUNTIPI_ADGUARD_IP             = var.runtipi_adguard_ip,
      WIREGUARD_CLIENT_CONFIGURATION = var.wireguard_client_configuration,
      SWAP_SIZE_GB                   = var.swap_size_gb,
      ENABLE_AUTO_REBOOT             = var.enable_auto_reboot,
      AUTO_REBOOT_TIME               = var.auto_reboot_time,
      DOCKER_DATA_ROOT_ON_VOLUME     = var.docker_data_root_on_block_volume,
      ENABLE_FAIL2BAN                = var.enable_fail2ban,
    }))
  }

  timeouts {
    create = "60m"
  }

  lifecycle {
    ignore_changes = [
      metadata["user_data"],
    ]

    # Fail fast at plan time when ApiKey auth is selected but the required
    # credential fields are missing, instead of a cryptic 401-NotAuthenticated
    # at apply. SecurityToken/InstancePrincipal/ResourcePrincipal read these
    # from the session profile or instance metadata, so they may stay null.
    precondition {
      condition = var.auth_method != "ApiKey" || (
        var.tenancy_ocid != null &&
        var.user_ocid != null &&
        var.oracle_api_key_fingerprint != null
      )
      error_message = "auth_method = \"ApiKey\" requires tenancy_ocid, user_ocid and oracle_api_key_fingerprint to be set."
    }

    # Always Free caps (ADR-0002). Refuse rather than warn: on a Free Tier
    # account OCI rejects the instance anyway, and on a Pay-As-You-Go account
    # the bill arrives silently.
    precondition {
      condition     = var.acknowledge_billable_resources || local.within_compute_caps
      error_message = "This configuration asks for ${var.instance_shape_config_ocpus} OCPUs and ${var.instance_shape_config_memory_gb} GB, above the Always Free cap of 2 OCPUs / 12 GB. Lower instance_shape_config_ocpus and instance_shape_config_memory_gb, or set acknowledge_billable_resources = true to provision billable resources deliberately."
    }

    # Home region (ADR-0003). Outside it nothing is Always Free, so the cost is
    # the whole deployment rather than the overage.
    precondition {
      condition     = var.acknowledge_billable_resources || local.region_is_home
      error_message = "region is set to ${var.region}, which is not the tenancy home region (${join(", ", local.home_regions)}). Outside the home region the instance and all of its storage are billed at full price, with no Always Free allocation whatsoever. Set region to the home region, or set acknowledge_billable_resources = true."
    }
  }
}
