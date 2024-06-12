

variable "tenancy_id" {
  description = "The tenancy id of the OCI Cloud Account in which to create the resources."
  type        = string
}

variable "region" {
  type        = string
  description = "The OCI region"
}

variable "compartment_id" {
  type        = string
  description = "compartment ocid"
}

variable "ad_count" {
  type        = number
  default     = 1
  description = "Number of ads"
}

variable "new_bits" {
  type        = number
  default     = 1
  description = "CIDR newbits"
}

variable "ad_number" {
  description = "the AD to place the operator host"
  default     = 1
  type        = number
}

variable "vcn_cidr" {
  default     = "10.0.0.0/16"
  type        = string
  description = "CIDR Subnet to use for the VCN, will be split into multiple /24s for the required private and public subnets"
}

variable "block_size" {
  type    = number
  default = 3
}

variable "cluster_name" {
  description = "Cluster name, lower case and without spaces. This will be used to set tags and name resources"
  type        = string
}

variable "tags" {
  description = "Contains default tags for this project"
  type        = map(string)
  default     = {}
}


variable "operator_shape" {
  description = "The shape of the operator instance."
  default = {
    shape = "VM.Standard.E3.Flex", ocpus = 1, memory = 8, boot_volume_size = 50
  }
  type = map(any)
}

variable "bastion_state" {
  description = "The target state for the instance. Could be set to RUNNING or STOPPED. (Updatable)"
  default     = "RUNNING"
  type        = string
}

variable "node_pool_shape" {
  default     = "VM.Standard.E3.Flex"
  description = "A shape is a template that determines the number of OCPUs, amount of memory, and other resources allocated to a newly created instance."
}

variable "image_operating_system" {
  default     = "Canonical Ubuntu"
  description = "The OS/image installed on all nodes in the node pool."
}
variable "image_operating_system_version" {
  default     = "20.04"
  description = "The OS/image version installed on all nodes in the node pool."
}

variable "k8s_cluster_properties" {
  default = {
    shape                   = "VM.Standard.E4.Flex"
    ocpus                   = 2
    memory                  = 32
    boot_volume_size        = 50
    node_pool_size          = 3
    worker_image_os_version = 7.9
    cni : "flannel"
  }
  description = "Default oke properties"
  type        = map(any)
}

variable "flannel_pods_cidr" {
  type        = string
  default     = "10.244.0.0/16"
  description = "Pods CIDR for Flannel"
}

variable "k8s_allow_rules_public_lb" {
  default = {}
  type    = any
}

variable "iac_group_name" {
  type        = string
  description = "iac group name"
  default     = "admin"
}

variable "os_user_name" {
  default     = "ubuntu"
  type        = string
  description = "os username for bastion host"
}

variable "inst_count" { default = 1 }

variable "num_ocpu" { default = 2 }


variable "sandbox_env" {
  default     = "playground"
  type        = string
  description = "sandbox environment"
}

variable "workload_name" {
  default     = "GovStack"
  type        = string
  description = "Workload Name"
}

variable "output_dir" {
  description = "where generate output"
  default     = "/iac-run-dir/output"
}

variable "repositories" {
  type    = list(string)
  default = [
    "app/usct/backend",
    "app/usct/frontend",
    "app/bp/frontend",
    "app/rpc/backend",
    "bb/im/sandbox-x-road/central-server",
    "bb/im/sandbox-x-road/security-server",
    "bb/payments/adapter",
    "bb/payments/emulator",
    "bb/digital-registries/emulator"
  ]
}

variable "is_public" {
  description = "If the type of repository is public."
  type        = bool
  default     = "false"
}

variable "ssl_certificate" {
  type        = string
  description = "ssl certificate file"
  default     = ""
}

variable "ssl_private_key" {
  type        = string
  description = "ssl certificate private key"
  default     = ""
}

variable "domain" {
  description = "A Valid DNS domain."
  type        = string
}