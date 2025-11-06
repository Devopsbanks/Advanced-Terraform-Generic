subscription_id = "9117002a-2308-428d-993b-9f46dfdfd10c"

rgs = {
  rg1 = {
    name       = "rg-test"
    location   = "West US"
    managed_by = "dev"
  }
}

vnets = {
  vnet1 = {
    name                = "vnet-test"
    resource_group_name = "rg-test"
    location            = "West US"
    address_space       = ["10.0.0.0/16"]

    subnet = [
      {
        subnet_name      = "subnet11"
        address_prefixes = ["10.0.1.0/24"]
      }
    ]
  }
}

pips = {
  pip1 = {
    name                = "pip-test1"
    resource_group_name = "rg-test"
    location            = "West US"
    allocation_method   = "Static"
  }
}

keys = {
  key1 = {
    kv_name                       = "key-anji-test-001"
    location                      = "West US"
    rg_name                       = "rg-test"
    sku_name                      = "standard"
    rbac_authorization_enabled    = true
    public_network_access_enabled = true
  }
}

# 🆕 Secure Secrets — auto-generated in Key Vault, not hardcoded
secrets = {
  secret_user = {
    kv_name     = "key-anji-test-001"
    rg_name     = "rg-test"
    secret_name = "adminuser"
  }
  secret_pass = {
    kv_name     = "key-anji-test-001"
    rg_name     = "rg-test"
    secret_name = "adminpassword"
  }
}

# 🧠 VM config without password in plain text
vms = {
  vm1 = {
    subnet_name = "subnet11"
    vnet_name   = "vnet-test"
    pip_name    = "pip-test1"
    kv_name     = "key-anji-test"
    # updated to unique kv name
    kv_name      = "key-anji-test-001"
    secret_name  = "adminuser"
    secret_value = "adminpassword"

    nic_name = "nic-test"
    ip_configuration = [
      {
        name                          = "internal"
        private_ip_address_allocation = "Dynamic"
        # provide explicit subnet id to ensure NIC creation has the subnet reference
        subnet_id = "/subscriptions/9117002a-2308-428d-993b-9f46dfdfd10c/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet11"
      }
    ]

    vm_name             = "vm1-test"
    resource_group_name = "rg-test"
    location            = "West US"
    size                = "Standard_F2"

    # ❌ Removed admin_password — will be fetched securely from Key Vault
    admin_username = "vm1"

    os_disk = [
      {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
      }
    ]

    source_image_reference = [
      {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts"
        version   = "latest"
      }
    ]
  }
}
