resource "azurerm_linux_virtual_machine_scale_set" "web" {
  name                = var.vmss_name
  location            = var.location
  resource_group_name = var.resource_group_name
  upgrade_mode        = "Automatic"

  sku                   = var.vm_size
  instances           = var.instance_count

  admin_username = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "24.04-LTS"
    version   = "latest"
  }

  network_interface {
    name    = "api-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      subnet_id                              = var.subnet_id
      load_balancer_backend_address_pool_ids = var.backend_pool_ids
      primary                                = true
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  health_probe_id = var.health_probe_id

  tags = var.tags
}