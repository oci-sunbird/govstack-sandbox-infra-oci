resource "oci_core_instance" "bastion" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  agent_config {
    are_all_plugins_disabled = false
    is_management_disabled   = false
    is_monitoring_disabled   = false
    plugins_config {
      desired_state = "ENABLED"
      name          = "Bastion"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "OS Management Service Agent"
    }
  }
  compartment_id = var.compartment_id
  create_vnic_details {
    assign_public_ip = true
    subnet_id        = local.public_subnet_id
    nsg_ids          = [oci_core_network_security_group.bastion.id]
  }
  display_name = "${local.cluster_domain}-bastion"
  launch_options {
    boot_volume_type = "PARAVIRTUALIZED"
    network_type     = "PARAVIRTUALIZED"
  }
  metadata = {
    ssh_authorized_keys = tls_private_key.compute_ssh_key.public_key_openssh
    user_data           = base64encode(templatefile("${path.module}/templates/bastion.user_data.tmpl", { ssh_keys = local.ssh_keys, vcn_cidr = var.vcn_cidr }))

  }

  shape = lookup(var.operator_shape, "shape", "VM.Standard.E4.Flex")

  dynamic "shape_config" {
    for_each = length(regexall("Flex", lookup(var.operator_shape, "shape", "VM.Standard.E4.Flex"))) > 0 ? [1] : []
    content {
      ocpus         = max(1, lookup(var.operator_shape, "ocpus", 1))
      memory_in_gbs = (lookup(var.operator_shape, "memory", 4) / lookup(var.operator_shape, "ocpus", 1)) > 64 ? (lookup(var.operator_shape, "ocpus", 1) * 4) : lookup(var.operator_shape, "memory", 4)
    }
  }

  source_details {
    source_type = "image"
    source_id   = local.bastion_image_id
  }

  state = var.bastion_state

  # prevent the operator from destroying and recreating itself if the image ocid/tagging/user data changes
  lifecycle {
    ignore_changes = [availability_domain, defined_tags, freeform_tags, metadata, source_details[0].source_id]
  }

  timeouts {
    create = "60m"
  }

}

