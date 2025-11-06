############################################
# Create Network Interface
############################################
resource "azurerm_network_interface" "nic" {
  for_each = var.vms

  name                = each.value.nic_name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  dynamic "ip_configuration" {
    for_each = each.value.ip_configuration
    content {
      name                                         = ip_configuration.value.name
      subnet_id                                    = try(ip_configuration.value.subnet_id, data.azurerm_subnet.subnet[each.key].id)
      private_ip_address_allocation                = ip_configuration.value.private_ip_address_allocation
      public_ip_address_id                         = try(ip_configuration.value.public_ip_address_id, data.azurerm_public_ip.pip[each.key].id)

      private_ip_address                           = try(ip_configuration.value.private_ip_address, null)
      private_ip_address_version                   = try(ip_configuration.value.private_ip_address_version, null)
      gateway_load_balancer_frontend_ip_configuration_id = try(ip_configuration.value.gateway_load_balancer_frontend_ip_configuration_id, null)
      primary                                      = try(ip_configuration.value.primary, false)
    }
  }

  auxiliary_mode                 = each.value.auxiliary_mode
  auxiliary_sku                  = each.value.auxiliary_sku
  dns_servers                    = each.value.dns_servers
  edge_zone                      = each.value.edge_zone
  ip_forwarding_enabled          = each.value.ip_forwarding_enabled
  accelerated_networking_enabled = each.value.accelerated_networking_enabled
  internal_dns_name_label        = each.value.internal_dns_name_label
}

############################################
# Create Linux Virtual Machine with Managed Identity
############################################
resource "azurerm_linux_virtual_machine" "virtual_machine" {
  for_each                        = var.vms
  name                            = each.value.vm_name
  resource_group_name             = each.value.resource_group_name
  location                        = each.value.location
  size                            = each.value.size

  # Admin credentials - prefer values provided via module input (environments pass these in).
  admin_username                  = each.value.admin_username
  admin_password                  = each.value.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id,
  ]

  ############################################
  # Enable System Assigned Managed Identity
  ############################################
  identity {
    type = "SystemAssigned"
  }

  ############################################
  # OS Disk Configuration
  ############################################
  dynamic "os_disk" {
    for_each = each.value.os_disk == null ? [] : each.value.os_disk
    content {
      caching              = os_disk.value.caching
      storage_account_type = os_disk.value.storage_account_type
      disk_size_gb         = os_disk.value.disk_size_gb
      name                 = os_disk.value.name
      write_accelerator_enabled = os_disk.value.write_accelerator_enabled
    }
  }

  ############################################
  # Source Image Reference
  ############################################
  dynamic "source_image_reference" {
    for_each = each.value.source_image_reference == null ? [] : each.value.source_image_reference
    content {
      publisher = source_image_reference.value.publisher
      offer     = source_image_reference.value.offer
      sku       = source_image_reference.value.sku
      version   = source_image_reference.value.version
    }
  }

  tags = {
    environment = "dev"
  }
}

############################################
# Assign Key Vault Secrets User Role to VM
############################################
resource "azurerm_role_assignment" "vm_secret_reader" {
  for_each             = var.vms
  scope                = data.azurerm_key_vault.kv[each.key].id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_virtual_machine.virtual_machine[each.key].identity[0].principal_id
}
