output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "web_subnet_id" {
  value = azurerm_subnet.web.id
}

output "app_subnet_id" {
  value = azurerm_subnet.app.id
}

output "db_subnet_id" {
  value = azurerm_subnet.db.id
}

output "firewall_subnet_id" {
  value = azurerm_subnet.firewall.id
}

output "bastion_subnet_id" {
  value = azurerm_subnet.bastion.id
}