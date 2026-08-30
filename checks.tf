# Always Free caps and home-region eligibility.
#
# See docs/adr/0002-always-free-cap-reduction.md and
# docs/adr/0003-require-explicit-home-region.md for the reasoning.
#
# The precondition blocks in compute.tf and storage.tf refuse to build above the
# caps unless var.acknowledge_billable_resources is set; the check block below
# is the advisory half, warning the users who did set it.

# Always Free eligibility is scoped to the tenancy home region. Skipped when
# tenancy_ocid is null (SecurityToken and principal auth read it from the
# session profile or instance metadata): with no tenancy to query the home
# region is unknowable here, and the check passes rather than blocking.
#
# Reading this requires `inspect tenancies` on the tenancy. A tenancy admin has
# it; a compartment-scoped service user may not, and the plan then fails on the
# data source read rather than on the precondition. try() below only guards the
# count = 0 case — a read failure aborts the plan and cannot be caught here.
data "oci_identity_region_subscriptions" "tenancy" {
  count = var.tenancy_ocid != null ? 1 : 0

  tenancy_id = var.tenancy_ocid
}

locals {
  home_regions = [
    for subscription in try(data.oci_identity_region_subscriptions.tenancy[0].region_subscriptions, []) :
    subscription.region_name if subscription.is_home_region
  ]

  # Unknown home region (no tenancy_ocid) is treated as a match: the module
  # cannot tell, so it does not block.
  region_is_home = length(local.home_regions) == 0 || contains(local.home_regions, var.region)

  within_compute_caps = var.instance_shape_config_ocpus <= 2 && var.instance_shape_config_memory_gb <= 12

  total_storage_gb   = var.instance_shape_boot_volume_size_gb + var.docker_volume_size_gb
  within_storage_cap = local.total_storage_gb <= 200
}

check "always_free_caps" {
  assert {
    condition     = local.within_compute_caps
    error_message = "Compute is above the Always Free cap of 2 OCPUs / 12 GB: this configuration asks for ${var.instance_shape_config_ocpus} OCPUs and ${var.instance_shape_config_memory_gb} GB. On a Pay-As-You-Go account the excess is billed; on a Free Tier account OCI refuses the instance, and existing instances above the cap have been terminated."
  }

  assert {
    condition     = local.within_storage_cap
    error_message = "Block storage is above the Always Free cap of 200 GB: this configuration asks for ${local.total_storage_gb} GB (${var.instance_shape_boot_volume_size_gb} GB boot volume plus ${var.docker_volume_size_gb} GB Docker volume). The excess is billed per GB per month."
  }

  assert {
    condition     = local.region_is_home
    error_message = "Region ${var.region} is not the tenancy home region (${join(", ", local.home_regions)}). Outside the home region there is no Always Free allocation at all: the instance and every GB of storage are billed at full price, not just the excess over the caps."
  }

  assert {
    condition     = local.within_compute_caps
    error_message = "An instance above the Always Free caps may not be recreatable once destroyed. Always Free Ampere A1 capacity is frequently exhausted, and 'Out of host capacity' on create is the common experience rather than the exception. Downsizing an existing instance in place is safe; destroying it to rebuild smaller may leave you with nothing."
  }
}
