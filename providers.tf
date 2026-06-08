provider "oci" {
  auth                = var.auth_method
  config_file_profile = var.config_file_profile

  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.oracle_api_key_fingerprint
  private_key_path = var.oracle_api_private_key_path
  region           = var.region
}
