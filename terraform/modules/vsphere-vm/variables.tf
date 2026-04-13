variable "vm_name" {
  type = string
}

variable "datacenter_id" {
  type = string
}

variable "datastore_id" {
  type = string
}

variable "resource_pool_id" {
  type = string
}

variable "network_id" {
  type = string
}

variable "template_guest_id" {
  type = string
}

variable "template_scsi_type" {
  type = string
}

variable "template_firmware" {
  type = string
}

variable "template_uuid" {
  type = string
}

variable "cpu_count" {
  type = number
}

variable "memory_mb" {
  type = number
}

variable "disk_gb" {
  type = number
}

variable "folder" {
  type    = string
  default = ""
}

variable "domain" {
  type = string
}

variable "dns_servers" {
  type = list(string)
}

variable "ipv4_gateway" {
  type = string
}

variable "network_adapter_type" {
  type = string
}

variable "customization_ipv4" {
  type    = bool
  default = false
}

variable "static_ipv4_address" {
  type    = string
  default = ""
}

variable "static_ipv4_prefix_length" {
  type    = number
  default = 0
}
