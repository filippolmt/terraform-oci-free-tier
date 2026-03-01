# Verify that default configuration produces expected Free Tier infrastructure

mock_provider "oci" {
  mock_data "oci_identity_availability_domain" {
    defaults = {
      name = "XYz1:EU-MILAN-1-AD-1"
    }
  }
  mock_data "oci_core_private_ips" {
    defaults = {
      private_ips = [{
        id = "ocid1.privateip.oc1..mock"
      }]
    }
  }
}

variables {
  compartment_ocid           = "ocid1.compartment.oc1..mock"
  tenancy_ocid               = "ocid1.tenancy.oc1..mock"
  user_ocid                  = "ocid1.user.oc1..mock"
  oracle_api_key_fingerprint = "aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99"
  ssh_public_key             = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAItest mock@test"
}

run "default_instance_config" {
  command = plan

  assert {
    condition     = oci_core_instance.instance.shape == "VM.Standard.A1.Flex"
    error_message = "Default shape should be VM.Standard.A1.Flex"
  }

  assert {
    condition     = oci_core_instance.instance.shape_config[0].ocpus == 4
    error_message = "Default OCPUs should be 4"
  }

  assert {
    condition     = oci_core_instance.instance.shape_config[0].memory_in_gbs == 24
    error_message = "Default memory should be 24GB"
  }

  assert {
    condition     = oci_core_instance.instance.display_name == "DockerHost"
    error_message = "Default display name should be DockerHost"
  }

  assert {
    condition     = oci_core_instance.instance.fault_domain == "FAULT-DOMAIN-2"
    error_message = "Default fault domain should be FAULT-DOMAIN-2"
  }

  assert {
    condition     = oci_core_instance.instance.is_pv_encryption_in_transit_enabled == true
    error_message = "PV encryption in transit should be enabled by default"
  }

  assert {
    condition     = oci_core_instance.instance.instance_options[0].are_legacy_imds_endpoints_disabled == true
    error_message = "Legacy IMDS endpoints should be disabled by default"
  }

  assert {
    condition     = oci_core_instance.instance.create_vnic_details[0].assign_public_ip == "false"
    error_message = "Direct public IP assignment should be disabled (uses reserved IP)"
  }
}

run "default_volume_config" {
  command = plan

  assert {
    condition     = tonumber(oci_core_instance.instance.source_details[0].boot_volume_size_in_gbs) == 50
    error_message = "Default boot volume should be 50GB"
  }

  assert {
    condition     = tonumber(oci_core_volume.docker_volume.size_in_gbs) == 150
    error_message = "Default Docker volume should be 150GB"
  }

  assert {
    condition     = tonumber(oci_core_volume.docker_volume.vpus_per_gb) == 10
    error_message = "Default vpus_per_gb should be 10 (Balanced tier)"
  }
}

run "default_network_config" {
  command = plan

  assert {
    condition     = oci_core_vcn.vcn.cidr_blocks[0] == "10.1.0.0/16"
    error_message = "Default VCN CIDR should be 10.1.0.0/16"
  }

  assert {
    condition     = oci_core_subnet.subnet.cidr_block == "10.1.0.0/24"
    error_message = "Default subnet CIDR should be 10.1.0.0/24"
  }
}

run "default_tags" {
  command = plan

  assert {
    condition     = oci_core_instance.instance.freeform_tags["ManagedBy"] == "Terraform"
    error_message = "Instance should have ManagedBy=Terraform tag"
  }

  assert {
    condition     = oci_core_vcn.vcn.freeform_tags["ManagedBy"] == "Terraform"
    error_message = "VCN should have ManagedBy=Terraform tag"
  }

  assert {
    condition     = oci_core_subnet.subnet.freeform_tags["ManagedBy"] == "Terraform"
    error_message = "Subnet should have ManagedBy=Terraform tag"
  }

  assert {
    condition     = oci_core_volume.docker_volume.freeform_tags["ManagedBy"] == "Terraform"
    error_message = "Docker volume should have ManagedBy=Terraform tag"
  }

  assert {
    condition     = oci_core_security_list.security_list.freeform_tags["ManagedBy"] == "Terraform"
    error_message = "Security list should have ManagedBy=Terraform tag"
  }

  assert {
    condition     = oci_core_internet_gateway.internet_gateway.freeform_tags["ManagedBy"] == "Terraform"
    error_message = "Internet gateway should have ManagedBy=Terraform tag"
  }
}
