locals {
  jumphostmap = {
    ansible_ssh_common_args = "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ProxyCommand=\"ssh -W %h:%p -i ${local_sensitive_file.compute_ssh_key.filename} -o StrictHostKeyChecking=no -q ${var.ansible_bastion_os_username}@${var.ansible_bastion_public_ip}\""
  }
  ansible_output_dir = "${var.ansible_base_output_dir}/functional-registry-app"
  ssh_private_key_file_map = {
    ansible_ssh_private_key_file = local_sensitive_file.compute_ssh_key.filename
  }
  iam_private_key_file_map = {
    ansible_bastion_iam_private_key_file = local_sensitive_file.bastion_iam_key.filename
  }
  ssl_cert_private_key_file_map = {
    ansible_ssl_cert_private_key_file = local_sensitive_file.ssl_cert_private_key.filename
  }
  ssl_cert_file_map = {
    ansible_ssl_cert_file = local_sensitive_file.ssl_cert.filename
  }

}

