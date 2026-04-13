variable "managed_existing_vms" {
  type = map(object({
    vm_name             = string
    cpu                 = number
    memory_mb           = number
    disk0_size_gb       = number
    network_name        = string
    network_adapter_type = string
    datastore           = string
    resource_pool_path  = string
    folder              = string
    guest_id            = string
    firmware            = string
    scsi_type           = string
  }))
  description = "Existing VMs to be managed with Terraform after import"
  default     = {}
}

variable "existing_vm_snapshot_enabled" {
  type        = bool
  description = "Create pre-change snapshots for imported existing VMs"
  default     = false
}

variable "existing_vm_snapshot_name" {
  type        = string
  description = "Snapshot name for Terraform-managed existing VMs"
  default     = "pre-change"
}

variable "template_deployments" {
  type = map(object({
    vm_name              = string
    template_name        = string
    cpu                  = number
    memory_mb            = number
    disk_gb              = number
    network_name         = string
    folder               = string
    domain               = string
    customization_ipv4   = bool
    static_ipv4_address  = string
    static_ipv4_netmask  = number
    ipv4_gateway         = string
  }))
  description = "VMs to deploy from template"
  default     = {}
}

variable "ova_deployments" {
  type = map(object({
    vm_name             = string
    local_ovf_path      = string
    cpu                 = number
    memory_mb           = number
    network_name        = string
    folder              = string
    disk_provisioning   = string
    ip_protocol         = string
    ip_allocation_policy = string
  }))
  description = "VMs to deploy from OVA/OVF"
  default     = {}
}

variable "iso_deployments" {
  type = map(object({
    vm_name             = string
    guest_id            = string
    cpu                 = number
    memory_mb           = number
    disk_gb             = number
    network_name        = string
    folder              = string
    iso_path            = string
  }))
  description = "VM shells to deploy from ISO for unattended OS installation"
  default     = {}
}
