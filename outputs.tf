# Output the OCID of the instance
output "instance_ocid" {
  description = "The OCID of the instance"
  value       = oci_core_instance.instance.id
}

# Output the private IP of the instance
output "private_ip" {
  description = "The private IP of the instance"
  value       = oci_core_instance.instance.private_ip
}

# Output the public IP of the instance
output "public_ip" {
  description = "The public IP of the instance"
  value       = oci_core_public_ip.public_ip.ip_address
}
