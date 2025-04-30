variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_ssh_key" {
  type = string
}
variable "address_space" {

}

variable "sql_admin_username" {
  type = string
}

variable "sql_admin_password" {
  type      = string
  sensitive = true
}

variable "private_dns_zone_name" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "admin_object_id" {
  type = string
}

variable "alert_email" {
  type = string
}

variable "tags" {
  type = map(string)
}