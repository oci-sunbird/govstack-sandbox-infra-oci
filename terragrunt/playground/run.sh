terragrunt run-all init
cd sandbox-infra-playground
rm -rf .terragrunt-cache
terragrunt apply -auto-approve --terragrunt-non-interactive --target=module.vcn
terragrunt apply -auto-approve --terragrunt-non-interactive
