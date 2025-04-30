resource "azurerm_mssql_server" "sql_server" {
  name                = var.sql_database_name
  resource_group_name = var.resource_group_name
  version = "12.0"
  administrator_login = var.admin_username
  administrator_login_password = var.admin_password
  location            = var.location
  tags = {
    environment = "production"
  }
}

resource "azurerm_mssql_database" "main" {
    name = var.sql_database_name
    server_id = azurerm_mssql_server.sql_server.id
    sku_name = "S0"
    max_size_gb = 3
    enclave_type = "VBS"
    zone_redundant = true
    collation = "SQL_Latin1_General_CP1_CI_AS"
    license_type = "LicenseIncluded"
    lifecycle {
      prevent_destroy = true
    }
}

resource "azurerm_private_endpoint" "sql_pe" {
  name                = "sql-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "sql-priv-conn"
    private_connection_resource_id = var.sql_server_name.main.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }
}

resource "azurerm_private_dns_zone" "sql" {
  name                = var.private_dns_zone_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_link" {
  name                  = "sql-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql.name
  virtual_network_id    = var.vnet_name.main.id
}