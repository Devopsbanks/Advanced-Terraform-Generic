module "resource_group" {
  source = "../../modules/azurerm_rg"
  rgs    = var.rgs
}

module "virtual_network" {
  depends_on = [module.resource_group]
  source     = "../../modules/azurerm_vnet"
  vnets      = var.vnets
}

module "public_ip" {
  depends_on = [module.resource_group]
  source     = "../../modules/azurerm_public_ip"
  pips       = var.pips
}

module "kv" {
  depends_on = [module.resource_group]
  source     = "../../modules/azurerm_key_vault"
  keys       = var.keys
}

module "secret" {
  depends_on = [module.kv]
  source     = "../../modules/azurerm_kv_secret"
  secrets    = var.secrets
}

# 🆕 Pass Key Vault secret values dynamically to VM
module "vm" {
  depends_on = [
    module.resource_group,
    module.public_ip,
    module.virtual_network,
    module.kv,
    module.secret
  ]

  source = "../../modules/azurerm_vm"

  vms = {
    for vm_name, vm_config in var.vms : vm_name => merge(vm_config, {
      # Password dynamically injected from Key Vault secret output (look up by secret_name)
      admin_password = try(module.secret.secret_values_by_name[vm_config.secret_name], module.secret.secret_values[vm_name])
    })
  }
}
