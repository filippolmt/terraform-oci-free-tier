locals {
  # Base ingress rules (always enabled)
  base_ingress_rules = [
    {
      description  = "Allow SSH"
      protocol     = "6"
      source       = "0.0.0.0/0"
      stateless    = false
      tcp_options  = { min = 22, max = 22 }
      udp_options  = null
      icmp_options = null
    },
    {
      description  = "Allow ICMP fragmentation needed"
      protocol     = "1"
      source       = "0.0.0.0/0"
      stateless    = false
      tcp_options  = null
      udp_options  = null
      icmp_options = { type = 3, code = 4 }
    }
  ]

  # Ping rule (optional, disabled by default)
  ping_ingress_rule = var.enable_ping ? [
    {
      description  = "Allow ICMP echo request (ping)"
      protocol     = "1"
      source       = "0.0.0.0/0"
      stateless    = false
      tcp_options  = null
      udp_options  = null
      icmp_options = { type = 8, code = 0 }
    }
  ] : []

  # RunTipi ingress rules (HTTP, HTTPS, WireGuard — only when enabled)
  runtipi_ingress_rules = var.install_runtipi ? [
    {
      description  = "Allow HTTP (RunTipi)"
      protocol     = "6"
      source       = "0.0.0.0/0"
      stateless    = false
      tcp_options  = { min = 80, max = 80 }
      udp_options  = null
      icmp_options = null
    },
    {
      description  = "Allow HTTPS (RunTipi)"
      protocol     = "6"
      source       = "0.0.0.0/0"
      stateless    = false
      tcp_options  = { min = 443, max = 443 }
      udp_options  = null
      icmp_options = null
    },
    {
      description  = "Allow WireGuard VPN (RunTipi)"
      protocol     = "17"
      source       = "0.0.0.0/0"
      stateless    = false
      tcp_options  = null
      udp_options  = { min = 51820, max = 51820 }
      icmp_options = null
    }
  ] : []

  # Transform simple custom rules into full format
  custom_ingress_rules = [
    for rule in var.custom_ingress_security_rules : {
      description  = rule.description
      protocol     = rule.protocol
      source       = rule.source
      stateless    = false
      tcp_options  = rule.protocol == "6" ? { min = rule.port_min, max = rule.port_max } : null
      udp_options  = rule.protocol == "17" ? { min = rule.port_min, max = rule.port_max } : null
      icmp_options = null
    }
  ]

  ingress_security_rules = concat(
    local.base_ingress_rules,
    local.ping_ingress_rule,
    local.runtipi_ingress_rules,
    local.custom_ingress_rules
  )
}

resource "oci_core_vcn" "vcn" {
  cidr_blocks    = [var.vcn_cidr_block]
  compartment_id = var.compartment_ocid
  display_name   = "VCN"
  dns_label      = "vcn"
  freeform_tags  = var.freeform_tags
}

resource "oci_core_subnet" "subnet" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  cidr_block          = var.subnet_cidr_block
  display_name        = "Subnet"
  dns_label           = "subnet"
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
    for_each = local.ingress_security_rules
    content {
      description = ingress_security_rules.value.description
      protocol    = ingress_security_rules.value.protocol
      source      = ingress_security_rules.value.source
      stateless   = ingress_security_rules.value.stateless

      dynamic "tcp_options" {
        for_each = ingress_security_rules.value.tcp_options != null ? [ingress_security_rules.value.tcp_options] : []
        content {
          min = tcp_options.value.min
          max = tcp_options.value.max
        }
      }

      dynamic "udp_options" {
        for_each = ingress_security_rules.value.udp_options != null ? [ingress_security_rules.value.udp_options] : []
        content {
          min = udp_options.value.min
          max = udp_options.value.max
        }
      }

      dynamic "icmp_options" {
        for_each = ingress_security_rules.value.icmp_options != null ? [ingress_security_rules.value.icmp_options] : []
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
        for_each = egress_security_rules.value.tcp_options != null ? [egress_security_rules.value.tcp_options] : []
        content {
          min = tcp_options.value.min
          max = tcp_options.value.max
        }
      }

      dynamic "udp_options" {
        for_each = egress_security_rules.value.udp_options != null ? [egress_security_rules.value.udp_options] : []
        content {
          min = udp_options.value.min
          max = udp_options.value.max
        }
      }

      dynamic "icmp_options" {
        for_each = egress_security_rules.value.icmp_options != null ? [egress_security_rules.value.icmp_options] : []
        content {
          type = icmp_options.value.type
          code = icmp_options.value.code
        }
      }
    }
  }
}
