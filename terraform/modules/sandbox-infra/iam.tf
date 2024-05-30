# # Individual Rules
# locals {
#   gitlab_instance_in_compartment_rule = ["ALL {instance.id = '${oci_core_instance.gitlab_server.id}'}"]
# }

# locals {
#   dynamic_group_matching_rules = concat(
#     local.gitlab_instance_in_compartment_rule
#   )
# }

# ## Temporarily commented till we get access to test this tenancy

# # resource "oci_identity_dynamic_group" "gitlab_dynamic_group" {
# #   name           = "${replace(var.domain, ".", "-")}-${var.cluster_name}-gitlab"
# #   description    = "${replace(var.domain, ".", "-")}-${var.cluster_name}-gitlab"
# #   compartment_id = var.tenancy_id
# #   matching_rule  = "ANY {${join(",", local.dynamic_group_matching_rules)}}"
# #   provider       = oci.home_region
# # }


resource "oci_identity_user" "bastion_iam_user" {
  compartment_id = var.tenancy_id
  description    = "${var.cluster_name}-bastion-ci"
  name           = "${var.cluster_name}-bastion-ci"
  freeform_tags  = merge({ Name = "${local.name}-bastion-ci" }, local.common_tags)
  provider       = oci.home
}

resource "oci_identity_group" "bastion_iam_group" {
  compartment_id = var.tenancy_id
  description    = var.iac_group_name
  name           = var.iac_group_name
  freeform_tags  = merge({ Name = "${var.iac_group_name}" }, var.tags)
  provider       = oci.home
}

resource "oci_identity_user_group_membership" "bastion_iam_user_group_membership" {
  group_id = oci_identity_group.bastion_iam_group.id
  user_id  = oci_identity_user.bastion_iam_user.id
  provider = oci.home
}

resource "oci_identity_api_key" "bastion_iam_user_key" {
  key_value = tls_private_key.bastion_user_key.public_key_pem
  user_id   = oci_identity_user.bastion_iam_user.id
  provider  = oci.home
}


resource "oci_identity_policy" "app_compartment_policies" {
  name           = "${var.cluster_name}-${var.domain}-bastion-policies"
  description    = "Bastion Compartment Policies"
  compartment_id = var.compartment_id
  statements     = local.app_compartment_statements
  provider       = oci.home
}