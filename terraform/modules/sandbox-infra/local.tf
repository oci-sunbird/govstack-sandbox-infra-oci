###
# Local copies of variables to allow for parsing
###

locals {
  networks = {
    for idx, subnet in concat(local.public_subnets_list, local.private_subnets_list) : subnet =>
    (subnet == "oke-control-plane") ? cidrsubnet(var.vcn_cidr, 12, 0) : cidrsubnet(var.vcn_cidr, 8, idx)
  }
}

locals {
  cluster_domain        = "${replace(var.cluster_name, "-", "")}.${var.domain}"
  cluster_parent_domain = join(".", [for idx, part in split(".", local.cluster_domain) : part if idx > 0])
  identifying_tags      = { Cluster = var.cluster_name, Domain = local.cluster_domain }
  common_tags           = merge(local.identifying_tags, var.tags)
  ads                   = slice(data.oci_identity_availability_domains.ads.availability_domains, 0, var.ad_count)
  public_subnets_list   = ["public-subnet", "oke-control-plane"]
  private_subnets_list  = ["private-subnet"]
  network_cidr_blocks = {
    for idx, subnet in concat(local.public_subnets_list, local.private_subnets_list) : subnet =>
    (subnet == "oke-control-plane") ? cidrsubnet(var.vcn_cidr, 12, 0) : cidrsubnet(var.vcn_cidr, 8, idx + 1)
  }
  public_subnet_cidrs  = [for subnet_name in local.public_subnets_list : local.network_cidr_blocks[subnet_name]]
  private_subnet_cidrs = [for subnet_name in local.private_subnets_list : local.network_cidr_blocks[subnet_name]]
  public_subnets = { for idx, name in local.public_subnets_list : "public_sub${idx + 1}" => {
    name       = name
    cidr_block = local.public_subnet_cidrs[idx]
    type       = "public"
    dns_label  = (name == "oke-control-plane") ? "okectrp" : "public"
  } }
  private_subnets = { for idx, name in local.private_subnets_list : "private_sub${idx + 1}" => {
    name       = name
    cidr_block = local.private_subnet_cidrs[idx]
    type       = "private"
    dns_label  = (name == "oke-control-plane") ? "okectrp" : "private"
  } }
  subnet_maps      = merge(local.public_subnets, local.private_subnets)
  public_subnet_id = lookup(module.vcn.subnet_id, "public-subnet", null)
  ssh_keys         = []

}

locals {
  gitlab_instance_in_compartment_rule = ["ALL {instance.id = '${oci_core_instance.bastion.id}'}"]
  dynamic_group_matching_rules = concat(
    local.gitlab_instance_in_compartment_rule
  )
}

locals {
  bastion_image_id = lookup(data.oci_core_images.node_pool_images.images[0], "id")
}



#####


locals {
  vcn_id                                         = module.vcn.vcn_id
  base_infra_private_subnet_cidr_block           = module.vcn.subnet_all_attributes.private_sub1.cidr_block
  base_infra_public_subnet_cidr_block            = module.vcn.subnet_all_attributes.public_sub1.cidr_block
  base_infra_oke_control_plane_subnet_cidr_block = module.vcn.subnet_all_attributes.public_sub2.cidr_block
  base_infra_private_subnet_id                   = module.vcn.subnet_id.private-subnet
  base_infra_public_subnet_id                    = module.vcn.subnet_id.public-subnet
  base_infra_oke_control_plane_subnet_id         = module.vcn.subnet_id.oke-control-plane
  oke_pod_cidrs                                  = (lookup(var.k8s_cluster_properties, "cni", "flannel") == "flannel") ? var.flannel_pods_cidr : local.base_infra_private_subnet_cidr_block
  cp_allowed_cidrs                               = ["${local.base_infra_private_subnet_cidr_block}", "${local.base_infra_public_subnet_cidr_block}"]
  home_region                                    = lookup(data.oci_identity_regions.home_region.regions[0], "name")
  oke_name                                       = "${var.workload_name}-${var.sandbox_env}"
}

locals {
  name        = var.cluster_name
  base_domain = "${replace(var.cluster_name, "-", "")}.${var.domain}"
}

locals {
  k8s_latest_version      = reverse(sort(data.oci_containerengine_cluster_option.oke.kubernetes_versions))[0]
  cni                     = lookup(var.k8s_cluster_properties, "cni", "flannel")
  kubernetes_version      = lookup(var.k8s_cluster_properties, "kubernetes_version", local.k8s_latest_version)
  worker_image_os_version = lookup(var.k8s_cluster_properties, "worker_image_os_version", 7.9)
  worker_shape            = lookup(var.k8s_cluster_properties, "shape", "VM.Standard.E4.Flex")
  worker_ocpu             = lookup(var.k8s_cluster_properties, "ocpus", "2")
  worker_memory           = lookup(var.k8s_cluster_properties, "memory", "16")
  worker_boot_volume_size = lookup(var.k8s_cluster_properties, "boot_volume_size", "50")
  node_pool_size          = lookup(var.k8s_cluster_properties, "node_pool_size", 3)
}

locals {
  worker_pools = {
    np1 = {
      mode   = "node-pool",
      size   = local.node_pool_size,
      shape  = local.worker_shape,
      create = true
    }
  }
}

locals {
  worker_shape_properties = {
    shape            = local.worker_shape
    ocpus            = local.worker_ocpu
    memory           = local.worker_memory
    boot_volume_size = local.worker_boot_volume_size
  }
}


locals {
  oke_subnets = {
    "bastion" = {
      "create" = "never"
      "id"     = local.base_infra_private_subnet_id
      "cidr"   = local.base_infra_private_subnet_cidr_block
    },
    "pub_lb" = {
      "create" = "never"
      "id"     = local.base_infra_public_subnet_id
      "cidr"   = local.base_infra_public_subnet_cidr_block
    },
    "cp" = {
      "create" = "never"
      "id"     = local.base_infra_oke_control_plane_subnet_id
      "cidr"   = local.base_infra_oke_control_plane_subnet_cidr_block
    },
    "int_lb" = {
      "create" = "never"
      "id"     = local.base_infra_private_subnet_id
      "cidr"   = local.base_infra_private_subnet_cidr_block
    },
    "operator" = {
      "create" = "never"
      "id"     = local.base_infra_private_subnet_id
      "cidr"   = local.base_infra_private_subnet_cidr_block
    },
    "pods" = {
      "create" = "never"
      "id"     = local.base_infra_private_subnet_id
      "cidr"   = local.base_infra_private_subnet_cidr_block
    },
    "workers" = {
      "create" = "never"
      "id"     = local.base_infra_private_subnet_id
      "cidr"   = local.base_infra_private_subnet_cidr_block
    }
  }
}

locals {
  app_compartment_statements = concat(
    local.bastion_policy_statements,
  )

  bastion_policy_statements = [
    "Allow group id ${oci_identity_group.bastion_iam_group.id} to manage cluster-family in compartment id ${var.compartment_id}",
    "Allow group id ${oci_identity_group.bastion_iam_group.id} to manage dns in compartment id ${var.compartment_id}",
    "Allow group id ${oci_identity_group.bastion_iam_group.id} to manage repos in compartment id ${var.compartment_id}",
  ]
}


locals {
  current_region         = [for item in data.oci_identity_regions.current_region.regions : item if lookup(item, "name", null) == var.region]
  ocir_docker_repository = join("", [lower(lookup(local.current_region[0], "key")), ".ocir.io"])
  ocir_namespace         = lookup(data.oci_objectstorage_namespace.ns, "namespace")
  ocir_url               = "${local.ocir_docker_repository}/${local.ocir_namespace}"
  docker_server          = local.ocir_docker_repository
  docker_user            = "${local.ocir_namespace}/${oci_identity_user.bastion_iam_user.name}"
}