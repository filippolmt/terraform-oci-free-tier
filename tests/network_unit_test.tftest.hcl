# Test firewall conditional logic in network.tf

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

# Default: RunTipi enabled, ping disabled, unrestricted egress
run "default_firewall_rules" {
  command = plan

  # 2 base (SSH + ICMP frag) + 3 RunTipi (HTTP + HTTPS + WireGuard) = 5
  assert {
    condition     = length(oci_core_security_list.security_list.ingress_security_rules) == 5
    error_message = "Default config should have 5 ingress rules (2 base + 3 RunTipi)"
  }

  # Unrestricted egress = 1 "allow all" rule
  assert {
    condition     = length(oci_core_security_list.security_list.egress_security_rules) == 1
    error_message = "Default config should have 1 unrestricted egress rule"
  }
}

run "runtipi_disabled" {
  command = plan
  variables {
    install_runtipi = false
  }

  # Only 2 base rules (SSH + ICMP fragmentation)
  assert {
    condition     = length(oci_core_security_list.security_list.ingress_security_rules) == 2
    error_message = "RunTipi disabled should have only 2 base ingress rules"
  }
}

run "ping_enabled" {
  command = plan
  variables {
    enable_ping = true
  }

  # 2 base + 1 ping + 3 RunTipi = 6
  assert {
    condition     = length(oci_core_security_list.security_list.ingress_security_rules) == 6
    error_message = "Ping enabled should add 1 ICMP echo rule (6 total)"
  }
}

run "ping_enabled_runtipi_disabled" {
  command = plan
  variables {
    enable_ping     = true
    install_runtipi = false
  }

  # 2 base + 1 ping = 3
  assert {
    condition     = length(oci_core_security_list.security_list.ingress_security_rules) == 3
    error_message = "Ping enabled + RunTipi disabled should have 3 ingress rules"
  }
}

run "custom_ingress_rules_added" {
  command = plan
  variables {
    custom_ingress_security_rules = [
      {
        description = "Custom TCP rule"
        protocol    = "6"
        port_min    = 8080
        port_max    = 8080
      },
      {
        description = "Custom UDP rule"
        protocol    = "17"
        port_min    = 9000
        port_max    = 9000
      }
    ]
  }

  # 2 base + 3 RunTipi + 2 custom = 7
  assert {
    condition     = length(oci_core_security_list.security_list.ingress_security_rules) == 7
    error_message = "Custom rules should be added to ingress (7 total)"
  }
}

run "restricted_egress" {
  command = plan
  variables {
    enable_unrestricted_egress = false
  }

  # Default restrictive rules: HTTPS + HTTP + DNS(UDP) + DNS(TCP) + NTP = 5
  assert {
    condition     = length(oci_core_security_list.security_list.egress_security_rules) == 5
    error_message = "Restricted egress should have 5 default rules"
  }
}

run "custom_ssh_source_cidr" {
  command = plan
  variables {
    ssh_source_cidr = "203.0.113.0/24"
  }

  # Rule count unchanged, but SSH source should be restricted
  assert {
    condition     = length(oci_core_security_list.security_list.ingress_security_rules) == 5
    error_message = "Custom SSH source CIDR should not change rule count"
  }
}
