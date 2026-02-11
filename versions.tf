
terraform {
  required_version = ">=1.3"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "8.0.0"
    }
  }
}
