############################################
# Fetch Subnet details
############################################
data "azurerm_subnet" "subnet" {
  for_each             = var.vms
  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.resource_group_name
}

############################################
# Fetch Public IP details
############################################
data "azurerm_public_ip" "pip" {
  for_each            = var.vms
  name                = each.value.pip_name
  resource_group_name = each.value.resource_group_name
}

############################################
# Fetch Key Vault details
############################################
data "azurerm_key_vault" "kv" {
  for_each            = var.vms
  name                = each.value.kv_name
  resource_group_name = each.value.resource_group_name
}

