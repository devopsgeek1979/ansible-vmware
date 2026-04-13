variable "vsphere_server" {
  type        = string
  description = "vCenter endpoint"
  default     = "192.168.1.10"
}

variable "vsphere_user" {
  type        = string
  description = "vCenter username"
}

variable "vsphere_password" {
  type        = string
  description = "vCenter password"
  sensitive   = true
}

variable "allow_unverified_ssl" {
  type        = bool
  description = "Allow self-signed vCenter cert"
  default     = true
}

variable "datacenter" {
  type        = string
  description = "vSphere datacenter name"
}

variable "cluster" {
  type        = string
  description = "vSphere compute cluster name"
}

variable "datastore" {
  type        = string
  description = "vSphere datastore name"
}

variable "network" {
  type        = string
  description = "vSphere network/portgroup name"
}

variable "template_name" {
  type        = string
  description = "Golden image/template name"
}

variable "vm_folder" {
  type        = string
  description = "Optional VM folder in datacenter"
  default     = ""
}

variable "vm_domain" {
  type        = string
  description = "DNS domain for guest customization"
  default     = "example.internal"
}

variable "dns_servers" {
  type        = list(string)
  description = "Guest DNS servers"
  default     = ["8.8.8.8", "1.1.1.1"]
}

variable "ipv4_gateway" {
  type        = string
  description = "IPv4 gateway for guests"
}

variable "network_adapter_type" {
  type        = string
  description = "VM NIC adapter type"
  default     = "vmxnet3"
}

variable "vm_name_prefix" {
  type        = string
  description = "Prefix for created VMs"
  default     = "ansible"
}

variable "tower_node_count" {
  type        = number
  description = "Number of Tower/Controller nodes"
  default     = 2
}

variable "tower_cpu" {
  type        = number
  description = "vCPU count per Tower node"
  default     = 4
}

variable "tower_memory_mb" {
  type        = number
  description = "Memory per Tower node in MB"
  default     = 8192
}

variable "tower_disk_gb" {
  type        = number
  description = "Disk size per Tower node in GB"
  default     = 120
}

variable "managed_linux_count" {
  type        = number
  description = "Number of managed Linux servers"
  default     = 3
}

variable "managed_cpu" {
  type        = number
  description = "vCPU count per managed Linux node"
  default     = 2
}

variable "managed_memory_mb" {
  type        = number
  description = "Memory per managed Linux node in MB"
  default     = 4096
}

variable "managed_disk_gb" {
  type        = number
  description = "Disk size per managed Linux node in GB"
  default     = 60
}
