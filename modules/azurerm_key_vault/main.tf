data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault" {
  for_each = var.keys

  name                        = each.value.kv_name
  location                    = each.value.location
  resource_group_name         = each.value.rg_name
  sku_name                    = each.value.sku_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id

  # ✅ Enable RBAC instead of Access Policies
  # Use the new attribute name to avoid provider deprecation warnings
  rbac_authorization_enabled   = true

  enabled_for_deployment           = each.value.enabled_for_deployment
  enabled_for_disk_encryption      = each.value.enabled_for_disk_encryption
  enabled_for_template_deployment  = each.value.enabled_for_template_deployment
  purge_protection_enabled         = each.value.purge_protection_enabled
  public_network_access_enabled    = each.value.public_network_access_enabled
  soft_delete_retention_days       = each.value.soft_delete_retention_days
  tags                             = each.value.tags

  # ✅ Optional network ACLs block
  dynamic "network_acls" {
    for_each = each.value.network_acls != null ? [each.value.network_acls] : []
    content {
      bypass                    = network_acls.value.bypass
      default_action             = network_acls.value.default_action
      ip_rules                   = network_acls.value.ip_rules
      virtual_network_subnet_ids = network_acls.value.virtual_network_subnet_ids
    }
  }
}

# ✅ Assign RBAC Role to Terraform SPN (or current user)
resource "azurerm_role_assignment" "key_vault_admin" {
  for_each            = var.keys
  scope               = azurerm_key_vault.key_vault[each.key].id
  role_definition_name = "Key Vault Administrator"
  principal_id        = data.azurerm_client_config.current.object_id
}
