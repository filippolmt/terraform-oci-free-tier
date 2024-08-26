output "instance_id" {
  description = "The OCID of the instance"
  value       = oci_core_instance.instance.id
}

output "" {
  description = ""
  value       = oci_core_instance.instance.private_ip
}

output "" {
  description = ""
  value       = oci_core_public_ip.public_ip.ip_address
}
