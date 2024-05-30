resource "oci_artifacts_container_repository" "this" {
  for_each = toset(var.repositories)

  compartment_id = var.compartment_id
  display_name   = each.key
  freeform_tags  = var.tags
  is_public      = var.is_public
}