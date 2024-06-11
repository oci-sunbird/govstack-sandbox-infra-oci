terraform {
  source = "git::${get_env("IAC_TERRAFORM_MODULES_REPO")}//terraform/modules/sandbox-infra?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}


generate "required_providers_override" {
  path = "required_providers_override.tf"

  if_exists = "overwrite_terragrunt"

  contents = <<EOF
terraform { 
  
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "${local.cloud_platform_vars.oci_provider_version}"
    }
  }
}
provider "oci" {
  region           = "${local.env_vars.region}"
}

EOF
}


inputs = {
  ad_count                  = local.env_vars.ad_count
  tenancy_id                = local.env_vars.tenancy_id
  compartment_id            = local.env_vars.compartment_id
  region                    = local.env_vars.region
  cluster_name              = local.env_vars.cluster_name
  tags                      = local.env_vars.tags
  k8s_allow_rules_public_lb = local.env_vars.k8s_allow_rules_public_lb
  ssl_private_key           = local.env_vars.ssl_private_key
  ssl_certificate           = local.env_vars.ssl_certificate
}

locals {
  env_vars = yamldecode(
    file("${find_in_parent_folders("environment.yaml")}")
  )
  cloud_platform_vars = yamldecode(
    file("${find_in_parent_folders("${get_env("CONTROL_CENTER_CLOUD_PROVIDER")}-vars.yaml")}")
  )
}

include "root" {
  path = find_in_parent_folders()
}