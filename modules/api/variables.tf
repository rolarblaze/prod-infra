
variable "vmss_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "instance_count" {
  type    = number
  default = 2
}

variable "vm_size" {
  type    = string
  default = "Standard_DS2_v2"
}

variable "admin_username" {
  type = string
}

variable "admin_ssh_key" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "health_probe_id" {
  type = string
}
variable "backend_pool_ids" {
  type = list(string)
}