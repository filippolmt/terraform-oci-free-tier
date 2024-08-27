output "instance_id" {
  description = "The OCID of the instance"
  value       = oci_core_instance.instance.id
}

output "private_ip" {
  description = "The private IP of the instance"
  value       = oci_core_instance.instance.private_ip
}

output "public_ip" {
  description = "The public IP of the instance"
  value       = oci_core_public_ip.public_ip.ip_address
}
