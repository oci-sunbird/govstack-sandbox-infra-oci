
resource "local_sensitive_file" "ansible_inventory" {
  content = templatefile(
    "${path.module}/templates/inventory.yaml.tmpl",
    { all_hosts              = merge(var.bastion_hosts),
      bastion_hosts          = var.bastion_hosts,
      bastion_hosts_var_maps = merge(var.bastion_hosts_var_maps, local.iam_private_key_file_map),
    all_hosts_var_maps = merge(var.all_hosts_var_maps, local.ssh_private_key_file_map) }

  )
  filename        = "${local.ansible_output_dir}/inventory"
  file_permission = "0600"
}


# resource "local_sensitive_file" "deployment_status" {
#   content = templatefile(
#     "${path.module}/templates/outputs.txt.tmpl",
#     { domain                           = var.bastion_hosts_var_maps["domain"],
#       sbrc_keycloak_admin_password     = var.bastion_hosts_var_maps["sbrc_keycloak_admin_password"],
#       sbrc_keycloak_admin_api_secret   = var.bastion_hosts_var_maps["sbrc_keycloak_admin_api_secret"],
#       filestorage_root_password        = var.bastion_hosts_var_maps["filestorage_root_password"],
#       postgres_admin_user              = var.bastion_hosts_var_maps["postgres_admin_user"],
#       postgres_connectionInfo_password = var.bastion_hosts_var_maps["postgres_connectionInfo_password"],
#       postgress_db_host                = var.bastion_hosts_var_maps["postgress_db_host"],
#       bastion_public_ip                = var.bastion_hosts_var_maps["bastion_public_ip"],
#       bastion_ssh_key = var.ansible_bastion_key })
#   filename        = "${local.ansible_output_dir}/outputs.txt"
#   file_permission = "0600"
# }


resource "local_sensitive_file" "deployment_status" {
  content = templatefile(
    "${path.module}/templates/outputs.txt.tmpl",
    { fingerprint       = var.bastion_hosts_var_maps["fingerprint"],
      bastion_user_id   = var.bastion_hosts_var_maps["bastion_user_id"],
      tenancy_id        = var.bastion_hosts_var_maps["tenancy_id"],
      region            = var.bastion_hosts_var_maps["region"],
      auth_token        = var.bastion_hosts_var_maps["auth_token"],
      bastion_iam_key   = var.bastion_hosts_var_maps["bastion_iam_key"],
      bastion_public_ip = var.bastion_hosts_var_maps["bastion_public_ip"],
      ocir_url          = var.bastion_hosts_var_maps["ocir_url"],
      docker_server     = var.bastion_hosts_var_maps["docker_server"],
      docker_user       = var.bastion_hosts_var_maps["docker_user"],
      oke_cluster_id    = var.bastion_hosts_var_maps["oke_cluster_id"],
  bastion_ssh_key = var.bastion_hosts_var_maps["bastion_ssh_key"] })
  filename        = "${local.ansible_output_dir}/outputs.txt"
  file_permission = "0600"
}

resource "null_resource" "run_ansible" {
  provisioner "local-exec" {
    command     = <<-EOT
          ansible-galaxy collection install ${var.ansible_collection_url},${var.ansible_collection_tag}
          ansible-playbook govstack.iac.usct_deploy -i ${local_sensitive_file.ansible_inventory.filename}
    EOT
    working_dir = path.module
  }
  triggers = {
    inventory_file_sha_hex = local_sensitive_file.ansible_inventory.id
    ansible_collection_tag = var.ansible_collection_tag
  }
  depends_on = [
    local_sensitive_file.ansible_inventory
  ]
}


resource "null_resource" "run_ansible_undeploy" {
  provisioner "local-exec" {
    when        = destroy
    command     = <<-EOT
          echo "Run ansible playbook for USCT undeploy"
          # ansible-playbook govstack.iac.usct_undeploy -i ${self.triggers.inventory_file_name}
    EOT
    working_dir = path.module
  }
  triggers = {
    ansible_collection_url = var.ansible_collection_url
    ansible_collection_tag = var.ansible_collection_tag
    inventory_file_name    = local_sensitive_file.ansible_inventory.filename

  }
  depends_on = [
    local_sensitive_file.ansible_inventory
  ]
}

resource "local_sensitive_file" "compute_ssh_key" {
  content         = var.ansible_bastion_key
  filename        = "${local.ansible_output_dir}/sshkey"
  file_permission = "0600"
}

resource "local_sensitive_file" "bastion_iam_key" {
  content         = var.ansible_bastion_iam_key
  filename        = "${local.ansible_output_dir}/bastion_user_api.key"
  file_permission = "0600"
}

