output "secret_values" {
  value = {
    for k, s in azurerm_key_vault_secret.key_vault_secret :
    k => s.value
  }
  sensitive = true
}

# Also expose the secrets keyed by the actual secret name stored in Key Vault
output "secret_values_by_name" {
  value = {
    for k, s in azurerm_key_vault_secret.key_vault_secret :
    s.name => s.value
  }
  sensitive = true
}
