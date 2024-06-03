output "application" {
  description = "Deployment Results"
  value       = data.local_file.output.content

}


data "local_file" "output" {
  filename = "${var.ansible_base_output_dir}/functional-registry-app/outputs.txt"
  depends_on = [
    local_sensitive_file.deployment_status
  ]
}
