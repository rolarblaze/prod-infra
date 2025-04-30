resource_group_name   = "prod-rg"
location              = "East US"
vnet_name             = "prod-vnet"
admin_username        = "azureadmin"
address_space         = ["10.0.0.0/16"]
admin_ssh_key         = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ..."
sql_admin_username    = "sqladmin"
sql_admin_password    = "StrongPassword123!"
private_dns_zone_name = "privatelink.database.windows.net"
tenant_id             = "your-tenant-guid"
admin_object_id       = "your-admin-aad-object-id"
alert_email           = "alerts@example.com"
tags = {
  environment = "production"
  owner       = "cloud-team"
}