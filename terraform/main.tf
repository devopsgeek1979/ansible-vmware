
provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = var.allow_unverified_ssl
}

data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

locals {
  tower_nodes = {
    for index in range(var.tower_node_count) :
    format("tower-%02d", index + 1) => {
      cpu    = var.tower_cpu
      memory = var.tower_memory_mb
      disk   = var.tower_disk_gb
    }
  }

  managed_linux_nodes = {
    for index in range(var.managed_linux_count) :
    format("linux-%02d", index + 1) => {
      cpu    = var.managed_cpu
      memory = var.managed_memory_mb
      disk   = var.managed_disk_gb
    }
  }
}

resource "vsphere_virtual_machine" "tower_vms" {
  for_each = local.tower_nodes

  name             = "${var.vm_name_prefix}-${each.key}"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.vm_folder

  num_cpus  = each.value.cpu
  memory    = each.value.memory
  guest_id  = data.vsphere_virtual_machine.template.guest_id
  firmware  = data.vsphere_virtual_machine.template.firmware
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = var.network_adapter_type
  }

  disk {
    label            = "disk0"
    size             = each.value.disk
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = replace("${var.vm_name_prefix}-${each.key}", "_", "-")
        domain    = var.vm_domain
      }

      network_interface {}

      ipv4_gateway    = var.ipv4_gateway
      dns_server_list = var.dns_servers
    }
  }
}

resource "vsphere_virtual_machine" "managed_linux_vms" {
  for_each = local.managed_linux_nodes

  name             = "${var.vm_name_prefix}-${each.key}"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.vm_folder

  num_cpus  = each.value.cpu
  memory    = each.value.memory
  guest_id  = data.vsphere_virtual_machine.template.guest_id
  firmware  = data.vsphere_virtual_machine.template.firmware
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = var.network_adapter_type
  }

  disk {
    label            = "disk0"
    size             = each.value.disk
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = replace("${var.vm_name_prefix}-${each.key}", "_", "-")
        domain    = var.vm_domain
      }

      network_interface {}

      ipv4_gateway    = var.ipv4_gateway
      dns_server_list = var.dns_servers
    }
  }
}
