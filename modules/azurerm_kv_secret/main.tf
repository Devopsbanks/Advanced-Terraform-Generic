# modules/azurerm_kv_secret/main.tf

# 1️⃣ Get the Key Vault reference for each secret
data "azurerm_key_vault" "key_vault" {
  for_each = var.secrets
  name                = each.value.kv_name
  resource_group_name = each.value.rg_name
}

# 2️⃣ Generate a random strong password/value for each secret
resource "random_password" "secret_value" {
  for_each = var.secrets
  length  = 20
  special = true
}

# 3️⃣ Store the generated secret in Azure Key Vault
resource "azurerm_key_vault_secret" "key_vault_secret" {
  for_each = var.secrets

  name         = each.value.secret_name
  value        = random_password.secret_value[each.key].result
  key_vault_id = data.azurerm_key_vault.key_vault[each.key].id

  content_type    = try(each.value.content_type, null)
  not_before_date = try(each.value.not_before_date, null)
  expiration_date = try(each.value.expiration_date, null)
  tags            = try(each.value.tags, null)
}
