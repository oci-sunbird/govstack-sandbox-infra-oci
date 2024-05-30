data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_id
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.compartment_id
  ad_number      = var.ad_number
}

data "oci_core_nat_gateway" "nat_gateway" {
  nat_gateway_id = module.vcn.nat_gateway_id
}

data "oci_identity_tenancy" "tenant_details" {
  tenancy_id = var.tenancy_id
}

data "oci_identity_regions" "home_region" {
  filter {
    name   = "key"
    values = [data.oci_identity_tenancy.tenant_details.home_region_key]
  }
}

data "oci_core_images" "node_pool_images" {
  compartment_id           = var.compartment_id
  operating_system         = var.image_operating_system
  operating_system_version = var.image_operating_system_version
  shape                    = var.node_pool_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}



data "oci_containerengine_cluster_option" "oke" {
  cluster_option_id = "all"
}
