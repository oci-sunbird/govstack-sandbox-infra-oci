
module "vcn" {
  source                   = "oracle-terraform-modules/vcn/oci"
  version                  = "3.6.0"
  compartment_id           = var.compartment_id
  create_internet_gateway  = true
  create_nat_gateway       = true
  create_service_gateway   = true
  freeform_tags            = merge({}, local.common_tags)
  subnets                  = local.subnet_maps
  vcn_cidrs                = [var.vcn_cidr]
  vcn_name                 = local.cluster_domain
  lockdown_default_seclist = false
}


resource "oci_core_network_security_group" "bastion" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  display_name   = "${local.cluster_domain}-bastion"
  freeform_tags  = merge({ Name = "${local.cluster_domain}-bastion" }, local.common_tags)
}


resource "oci_core_network_security_group_security_rule" "bastion_ssh" {
  network_security_group_id = oci_core_network_security_group.bastion.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 22
      min = 22
    }
    source_port_range {
      max = 22
      min = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "bastion_egress_all" {
  network_security_group_id = oci_core_network_security_group.bastion.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}



