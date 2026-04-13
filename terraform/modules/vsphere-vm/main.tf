resource "vsphere_virtual_machine" "this" {
  name             = var.vm_name
  resource_pool_id = var.resource_pool_id
  datastore_id     = var.datastore_id
  folder           = var.folder

  num_cpus = var.cpu_count
  memory   = var.memory_mb
  guest_id = var.template_guest_id
  firmware = var.template_firmware
  scsi_type = var.template_scsi_type

  network_interface {
    network_id   = var.network_id
    adapter_type = var.network_adapter_type
  }

  disk {
    label            = "disk0"
    size             = var.disk_gb
    thin_provisioned = true
  }

  clone {
    template_uuid = var.template_uuid

    customize {
      linux_options {
        host_name = var.vm_name
        domain    = var.domain
      }

      network_interface {
        ipv4_address = var.customization_ipv4 ? var.static_ipv4_address : null
        ipv4_netmask = var.customization_ipv4 ? var.static_ipv4_prefix_length : null
      }

      ipv4_gateway    = var.customization_ipv4 ? var.ipv4_gateway : null
      dns_server_list = var.dns_servers
    }
  }
}
