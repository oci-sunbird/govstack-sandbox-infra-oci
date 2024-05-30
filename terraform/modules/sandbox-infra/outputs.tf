
output "bastion_ssh_key" {
  sensitive = true
  value     = tls_private_key.compute_ssh_key.private_key_pem
}

output "bastion_public_ip" {
  value = oci_core_instance.bastion.public_ip
}

output "bastion_os_username" {
  value = var.os_user_name
}


output "all_hosts_var_maps" {
  value = {
    ansible_ssh_user    = var.os_user_name
    ansible_ssh_retries = "10"
    base_domain         = local.base_domain
  }
}



output "bastion_hosts_var_maps" {
  sensitive = true
  value = {
    ansible_ssh_common_args = "-o StrictHostKeyChecking=no"
    egress_gateway_cidr     = var.vcn_cidr
    bastion_public_ip       = oci_core_instance.bastion.public_ip
    bastion_user_id         = oci_identity_user.bastion_iam_user.id
    fingerprint             = oci_identity_api_key.bastion_iam_user_key.fingerprint
    tenancy_id              = var.tenancy_id
    compartment_id          = var.compartment_id
    zone_compartment_id     = var.compartment_id
    region                  = var.region
    oke_k8s_cluster_id      = module.k8s_infra.cluster_id
    nsg_lb_oke_k8s_cluster  = module.k8s_infra.pub_lb_nsg_id
    oke_k8s_cluster_name    = local.oke_name

  }
}

output "bastion_hosts" {
  value = { bastion = oci_core_instance.bastion.public_ip }
}


output "bastion_iam_key" {
  sensitive = true
  value     = tls_private_key.bastion_user_key.private_key_pem
}


