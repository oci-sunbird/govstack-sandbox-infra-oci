

resource "oci_identity_user" "bastion_iam_user" {
  compartment_id = var.tenancy_id
  description    = "${var.cluster_name}-bastion-ci"
  name           = "${var.cluster_name}-bastion-ci"
  freeform_tags  = merge({ Name = "${local.name}-bastion-ci" }, local.common_tags)
  provider       = oci.home
}

resource "oci_identity_group" "bastion_iam_group" {
  compartment_id = var.tenancy_id
  description    = "${var.iac_group_name}-bastion-${var.workload_name}-${var.sandbox_env}"
  name           = "${var.iac_group_name}-bastion-${var.workload_name}-${var.sandbox_env}"
  freeform_tags  = merge({ Name = "${var.iac_group_name}-bastion-${var.workload_name}-${var.sandbox_env}" }, var.tags)
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


resource "oci_identity_auth_token" "bastion_user_auth_token" {
  description = "auth token for ocir authentication"
  user_id     = oci_identity_user.bastion_iam_user.id
  provider    = oci.home
}

resource "oci_identity_policy" "app_compartment_policies" {
  name           = "${var.cluster_name}-${var.domain}-bastion-policies"
  description    = "Bastion Compartment Policies"
  compartment_id = var.compartment_id
  statements     = local.app_compartment_statements
  provider       = oci.home
}