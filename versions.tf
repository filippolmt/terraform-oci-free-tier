
terraform {
  required_version = ">=1.3"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "5.45.0"
    }
  }
}
