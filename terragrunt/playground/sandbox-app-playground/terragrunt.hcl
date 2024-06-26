terraform {
  source = "git::${get_env("IAC_TERRAFORM_MODULES_REPO")}//terraform/modules/sandbox-app?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}

dependency "sandbox_infra" {
  config_path = "../sandbox-infra-playground"
  mock_outputs = {
    bastion_hosts                = {}
    bastion_hosts_var_maps       = {}
    all_hosts_var_maps           = {}
    bastion_ssh_key              = "key"
    bastion_iam_key              = "key"
    bastion_os_username          = "null"
    bastion_public_ip            = "null"
    ansible_ssl_cert_private_key = "null"
    ansible_ssl_cert             = "null"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

inputs = {
  bastion_hosts                = dependency.sandbox_infra.outputs.bastion_hosts
  bastion_hosts_var_maps       = dependency.sandbox_infra.outputs.bastion_hosts_var_maps
  all_hosts_var_maps           = dependency.sandbox_infra.outputs.all_hosts_var_maps
  ansible_bastion_key          = dependency.sandbox_infra.outputs.bastion_ssh_key
  ansible_bastion_os_username  = dependency.sandbox_infra.outputs.bastion_os_username
  ansible_bastion_public_ip    = dependency.sandbox_infra.outputs.bastion_public_ip
  ansible_bastion_iam_key      = dependency.sandbox_infra.outputs.bastion_iam_key
  ansible_ssl_cert_private_key = dependency.sandbox_infra.outputs.bastion_hosts_var_maps["ssl_private_key"]
  ansible_ssl_cert             = dependency.sandbox_infra.outputs.bastion_hosts_var_maps["ssl_certificate"]
  ansible_collection_tag       = local.env_vars.ansible_collection_tag
  ansible_collection_url       = local.env_vars.ansible_collection_url
  ansible_base_output_dir      = get_env("ANSIBLE_BASE_OUTPUT_DIR")
}

locals {
  env_vars = yamldecode(
  file("${find_in_parent_folders("environment.yaml")}"))
}

include "root" {
  path = find_in_parent_folders()
}
