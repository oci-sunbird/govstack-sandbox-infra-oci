variable "ansible_collection_url" {
  default = "git+https://github.com/oci-sunbird/govstack-sandbox-infra-oci.git#/ansible/govstack/iac"
}

variable "ansible_collection_tag" {
  default = "main"
}

variable "ansible_bastion_key" {
  description = "ssh key for bastion host"
  sensitive   = true
}

variable "ansible_bastion_iam_key" {
  description = "api key for bastion user"
  sensitive   = true
}


variable "ansible_bastion_public_ip" {
  description = "ip for bastion host"
}

variable "ansible_bastion_os_username" {
  description = "username for bastion host"
}

variable "ansible_base_output_dir" {
  description = "where to read/write ansible inv/etc"
  default     = "/iac-run-dir/output"
}

variable "bastion_hosts" {
  type        = map(any)
  description = "map of hosts to run bastion and netclient"
}

variable "bastion_hosts_var_maps" {
  type        = map(any)
  description = "var map for bastion hosts"
}


variable "all_hosts_var_maps" {
  type        = map(any)
  description = "var map for all hosts"
}
