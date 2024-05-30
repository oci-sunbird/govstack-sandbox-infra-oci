# module "k8s_infra" {
#   source                       = "oracle-terraform-modules/oke/oci"
#   version                      = "5.1.0"
#   compartment_id               = var.compartment_id
#   worker_compartment_id        = var.compartment_id
#   home_region                  = local.home_region
#   region                       = var.region
#   create_vcn                   = "false"
#   vcn_id                       = local.vcn_id
#   subnets                      = local.oke_subnets
#   pods_cidr                    = local.oke_pod_cidrs
#   cni_type                     = local.cni
#   cluster_name                 = local.oke_name
#   create_cluster               = true
#   kubernetes_version           = local.kubernetes_version
#   control_plane_is_public      = false
#   create_bastion               = false
#   create_operator              = false
#   allow_bastion_cluster_access = true
#   allow_pod_internet_access    = true
#   cluster_freeform_tags        = var.tags
#   control_plane_allowed_cidrs  = local.cp_allowed_cidrs
#   load_balancers               = "public"
#   worker_image_os_version      = local.worker_image_os_version
#   worker_shape                 = local.worker_shape_properties
#   worker_pools                 = local.worker_pools
#   allow_worker_ssh_access      = true
#   state_id                     = var.sandbox_env
#   allow_rules_public_lb        = var.k8s_allow_rules_public_lb

#   providers = {
#     oci      = oci.current_region
#     oci.home = oci.home
#   }

# }