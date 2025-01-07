output "github_actions_terraform_credentials" {
  value = module.github_actions_terraform.github_actions_terraform_credentials
  sensitive = true
}

output "github_actions_acr_push_credentials" {
  value = module.aurora.github_actions_acr_push_credentials
  sensitive = true
}
