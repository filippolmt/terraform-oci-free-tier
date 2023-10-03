output "instance_id" {
  description = "The OCID of the instance"
  value       = ["${oci_core_instance.instance.id}"]
}

output "private_ip" {
  description = "The private IP of the instance"
  value       = ["${oci_core_instance.instance.private_ip}"]
}

output "public_ip" {
  description = "The public IP of the instance"
  value       = [oci_core_public_ip.public_ip.ip_address]
}

output "connect_with_ssh" {
  description = "The command to connect to the instance with SSH"
  value       = [oci_core_instance_console_connection.instance_console_connection.connection_string]
}

output "connect_with_vnc" {
  description = "The command to connect to the instance with VNC"
  value       = [oci_core_instance_console_connection.instance_console_connection.vnc_connection_string]
}
