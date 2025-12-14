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

output "vcn_id" {
  description = "The OCID of the VCN"
  value       = oci_core_vcn.vcn.id
}

output "subnet_id" {
  description = "The OCID of the subnet"
  value       = oci_core_subnet.subnet.id
}

output "docker_volume_id" {
  description = "The OCID of the Docker volume"
  value       = oci_core_volume.docker_volume.id
}

output "availability_domain" {
  description = "The availability domain where resources are deployed"
  value       = data.oci_identity_availability_domain.ad.name
}

output "ssh_connection" {
  description = "SSH command to connect to the instance"
  value       = "ssh ubuntu@${oci_core_public_ip.public_ip.ip_address}"
}
