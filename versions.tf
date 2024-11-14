
terraform {
  required_version = ">=1.3"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "6.18.0"
    }
  }
}
