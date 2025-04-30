output "backend_pool_id" {
  value = tolist(azurerm_application_gateway.appgw.backend_address_pool)[0].id
}

output "health_probe_id" {
  value = tolist(azurerm_application_gateway.appgw.probe)[0].id
}
