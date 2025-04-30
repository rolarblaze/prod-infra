module "vnet" {
  source              = "../../modules/vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  vnet_name           = var.vnet_name
}

module "nsg" {
  source              = "../../modules/nsg"
  resource_group_name = var.resource_group_name
  location            = var.location
  web_subnet_id       = module.vnet.web_subnet_id
  app_subnet_id       = module.vnet.app_subnet_id
  db_subnet_id        = module.vnet.db_subnet_id

}

module "key_vault" {
  source              = "../../modules/key_vault"
  resource_group_name = var.resource_group_name
  location            = var.location
  key_vault_name      = "prod-keyvault"
  tenant_id           = var.tenant_id
  object_id           = var.admin_object_id
}

module "firewall" {
  source              = "../../modules/firewall"
  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_name           = var.vnet_name
  firewall_subnet_id  = module.vnet.firewall_subnet_id
}

module "bastion" {
  source              = "../../modules/bastion"
  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_name           = var.vnet_name
  bastion_subnet_id   = module.vnet.bastion_subnet_id
  public_ip_name      = "bastion-pip"
}

module "app_gateway" {
  source              = "../../modules/app_gateway"
  resource_group_name = var.resource_group_name
  location            = var.location
  appgw_name          = "prod-appgw"
  subnet_id           = module.vnet.web_subnet_id
  backend_ip          = "10.0.2.4" # Pointing to Web VMSS internal IP pool (sample IP)
  capacity            = 2
}

module "VMSS" {
  source              = "../../modules/VMSS"
  resource_group_name = var.resource_group_name
  location            = var.location
  vmss_name           = "prod-web-vmss"
  subnet_id           = module.vnet.web_subnet_id
  backend_pool_ids    = [module.app_gateway.backend_pool_id]
  health_probe_id     = module.app_gateway.health_probe_id
  instance_count      = 2
  vm_size             = "Standard_DS2_v2"
  admin_username      = var.admin_username
  admin_ssh_key       = var.admin_ssh_key
  tags                = var.tags
}

module "api" {
  source              = "../../modules/api"
  vmss_name           = "prod-api-vmss"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.vnet.app_subnet_id
  backend_pool_ids    = [module.app_gateway.backend_pool_id]
  health_probe_id     = module.app_gateway.health_probe_id
  instance_count      = 2
  vm_size             = "Standard_DS2_v2"
  admin_username      = var.admin_username
  admin_ssh_key       = var.admin_ssh_key
  tags                = var.tags
  depends_on          = [module.app_gateway]

}

module "sql_db" {
  source                = "../../modules/sql_db"
  resource_group_name   = var.resource_group_name
  location              = var.location
  sql_server_name       = "prod-sql-server"
  sql_database_name     = "prod-db"
  admin_username        = var.sql_admin_username
  admin_password        = var.sql_admin_password
  subnet_id             = module.vnet.app_subnet_id
  vnet_name             = var.vnet_name
  private_dns_zone_name = var.private_dns_zone_name
}


module "monitoring" {
  source                       = "../../modules/monitoring"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  log_analytics_workspace_name = "prod-law"
  alert_email                  = var.alert_email

}


