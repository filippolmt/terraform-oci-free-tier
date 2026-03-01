# Test variable validation rules enforce Free Tier constraints and input formats

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

# --- Region validation ---

run "invalid_region" {
  command = plan
  variables {
    region = "invalid-region-1"
  }
  expect_failures = [var.region]
}

# --- Instance display name validation ---

run "invalid_display_name_starts_with_digit" {
  command = plan
  variables {
    instance_display_name = "1BadName"
  }
  expect_failures = [var.instance_display_name]
}

run "invalid_display_name_too_long" {
  command = plan
  variables {
    # 64 characters — exceeds the 63-character OCI hostname label limit
    instance_display_name = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789ab"
  }
  expect_failures = [var.instance_display_name]
}

# --- CIDR validation ---

run "invalid_vcn_cidr" {
  command = plan
  variables {
    vcn_cidr_block = "not-a-cidr"
  }
  expect_failures = [var.vcn_cidr_block]
}

run "invalid_subnet_cidr" {
  command = plan
  variables {
    subnet_cidr_block = "not-a-cidr"
  }
  expect_failures = [var.subnet_cidr_block]
}

# --- Free Tier OCPU limits ---

run "ocpus_exceeds_free_tier" {
  command = plan
  variables {
    instance_shape_config_ocpus = 5
  }
  expect_failures = [var.instance_shape_config_ocpus]
}

run "ocpus_below_minimum" {
  command = plan
  variables {
    instance_shape_config_ocpus = 0
  }
  expect_failures = [var.instance_shape_config_ocpus]
}

# --- Free Tier memory limits ---

run "memory_exceeds_free_tier" {
  command = plan
  variables {
    instance_shape_config_memory_gb = 25
  }
  expect_failures = [var.instance_shape_config_memory_gb]
}

run "memory_below_minimum" {
  command = plan
  variables {
    instance_shape_config_memory_gb = 0
  }
  expect_failures = [var.instance_shape_config_memory_gb]
}

# --- Volume size limits ---

run "boot_volume_below_minimum" {
  command = plan
  variables {
    instance_shape_boot_volume_size_gb = 49
  }
  expect_failures = [var.instance_shape_boot_volume_size_gb]
}

run "docker_volume_below_minimum" {
  command = plan
  variables {
    docker_volume_size_gb = 49
  }
  expect_failures = [var.docker_volume_size_gb]
}

# --- Fault domain validation ---

run "invalid_fault_domain" {
  command = plan
  variables {
    fault_domain = "FAULT-DOMAIN-4"
  }
  expect_failures = [var.fault_domain]
}

# --- Availability domain validation ---

run "availability_domain_below_range" {
  command = plan
  variables {
    availability_domain_number = 0
  }
  expect_failures = [var.availability_domain_number]
}

run "availability_domain_above_range" {
  command = plan
  variables {
    availability_domain_number = 4
  }
  expect_failures = [var.availability_domain_number]
}

# --- SSH source CIDR validation ---

run "invalid_ssh_source_cidr" {
  command = plan
  variables {
    ssh_source_cidr = "not-a-cidr"
  }
  expect_failures = [var.ssh_source_cidr]
}

# --- WireGuard configuration validation ---

run "invalid_wireguard_config" {
  command = plan
  variables {
    wireguard_client_configuration = "InvalidConfig"
  }
  expect_failures = [var.wireguard_client_configuration]
}

# --- Custom ingress rules validation ---

run "custom_rule_invalid_protocol" {
  command = plan
  variables {
    custom_ingress_security_rules = [{
      protocol = "99"
      port_min = 8080
      port_max = 8080
    }]
  }
  expect_failures = [var.custom_ingress_security_rules]
}

run "custom_rule_port_out_of_range" {
  command = plan
  variables {
    custom_ingress_security_rules = [{
      protocol = "6"
      port_min = 0
      port_max = 80
    }]
  }
  expect_failures = [var.custom_ingress_security_rules]
}

run "custom_rule_port_min_greater_than_max" {
  command = plan
  variables {
    custom_ingress_security_rules = [{
      protocol = "6"
      port_min = 8080
      port_max = 80
    }]
  }
  expect_failures = [var.custom_ingress_security_rules]
}

run "custom_rule_invalid_source_cidr" {
  command = plan
  variables {
    custom_ingress_security_rules = [{
      protocol = "6"
      source   = "not-a-cidr"
      port_min = 80
      port_max = 80
    }]
  }
  expect_failures = [var.custom_ingress_security_rules]
}

# --- Boundary testing (valid values at limits) ---

run "valid_boundary_max_values" {
  command = plan
  variables {
    instance_shape_config_ocpus        = 4
    instance_shape_config_memory_gb    = 24
    instance_shape_boot_volume_size_gb = 50
    docker_volume_size_gb              = 50
  }

  assert {
    condition     = oci_core_instance.instance.shape_config[0].ocpus == 4
    error_message = "4 OCPUs (Free Tier max) should be valid"
  }

  assert {
    condition     = oci_core_instance.instance.shape_config[0].memory_in_gbs == 24
    error_message = "24GB RAM (Free Tier max) should be valid"
  }

  assert {
    condition     = tonumber(oci_core_instance.instance.source_details[0].boot_volume_size_in_gbs) == 50
    error_message = "50GB boot volume (minimum) should be valid"
  }

  assert {
    condition     = tonumber(oci_core_volume.docker_volume.size_in_gbs) == 50
    error_message = "50GB Docker volume (minimum) should be valid"
  }
}

run "valid_boundary_min_values" {
  command = plan
  variables {
    instance_shape_config_ocpus     = 1
    instance_shape_config_memory_gb = 1
  }

  assert {
    condition     = oci_core_instance.instance.shape_config[0].ocpus == 1
    error_message = "1 OCPU (minimum) should be valid"
  }

  assert {
    condition     = oci_core_instance.instance.shape_config[0].memory_in_gbs == 1
    error_message = "1GB RAM (minimum) should be valid"
  }
}
