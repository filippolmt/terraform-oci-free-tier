resource "oci_core_volume" "docker_volume" {
  display_name        = "DockerVolume"
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domain.ad.name
  size_in_gbs         = var.docker_volume_size_gb
  vpus_per_gb         = 10
  kms_key_id          = var.kms_key_id
  freeform_tags       = var.freeform_tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "oci_core_volume_attachment" "docker_volume_attachment" {
  display_name    = "DockerVolumeAttachment"
  instance_id     = oci_core_instance.instance.id
  volume_id       = oci_core_volume.docker_volume.id
  attachment_type = "paravirtualized"
}

resource "oci_core_volume_backup_policy" "docker_volume_backup_policy" {
  display_name   = "DockerVolumeBackupPolicy"
  compartment_id = var.compartment_ocid
  freeform_tags  = var.freeform_tags

  schedules {
    backup_type       = "INCREMENTAL"
    period            = "ONE_DAY"
    hour_of_day       = "1"
    offset_type       = "STRUCTURED"
    retention_seconds = 259200
    time_zone         = "REGIONAL_DATA_CENTER_TIME"
  }
}

resource "oci_core_volume_backup_policy_assignment" "docker_volume_backup_policy_assignment" {
  asset_id  = oci_core_volume.docker_volume.id
  policy_id = oci_core_volume_backup_policy.docker_volume_backup_policy.id
}
