locals {
  managed_existing_networks = toset([for vm in values(var.managed_existing_vms) : vm.network_name])
  managed_existing_datastores = toset([for vm in values(var.managed_existing_vms) : vm.datastore])
  managed_existing_resource_pools = toset([for vm in values(var.managed_existing_vms) : vm.resource_pool_path])

  template_names = toset([for vm in values(var.template_deployments) : vm.template_name])
  template_networks = toset([for vm in values(var.template_deployments) : vm.network_name])

  ova_networks = toset([for vm in values(var.ova_deployments) : vm.network_name])
  iso_networks = toset([for vm in values(var.iso_deployments) : vm.network_name])
}

data "vsphere_network" "managed_existing" {
  for_each      = local.managed_existing_networks
  name          = each.value
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "managed_existing" {
  for_each      = local.managed_existing_datastores
  name          = each.value
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "managed_existing" {
  for_each      = local.managed_existing_resource_pools
  name          = each.value
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "managed_existing" {
  for_each = var.managed_existing_vms

  name             = each.value.vm_name
  resource_pool_id = data.vsphere_resource_pool.managed_existing[each.value.resource_pool_path].id
  datastore_id     = data.vsphere_datastore.managed_existing[each.value.datastore].id
  folder           = each.value.folder

  num_cpus  = each.value.cpu
  memory    = each.value.memory_mb
  guest_id  = each.value.guest_id
  firmware  = each.value.firmware
  scsi_type = each.value.scsi_type

  network_interface {
    network_id   = data.vsphere_network.managed_existing[each.value.network_name].id
    adapter_type = each.value.network_adapter_type
  }

  disk {
    label            = "disk0"
    size             = each.value.disk0_size_gb
    thin_provisioned = true
  }
}

data "vsphere_virtual_machine" "managed_existing_source" {
  for_each      = var.managed_existing_vms
  name          = each.value.vm_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine_snapshot" "managed_existing_prechange" {
  for_each = var.existing_vm_snapshot_enabled ? data.vsphere_virtual_machine.managed_existing_source : {}

  virtual_machine_uuid = each.value.uuid
  snapshot_name        = "${var.existing_vm_snapshot_name}-${each.key}"
  description          = "Snapshot before day-2 infra changes"
  memory               = false
  quiesce              = true
  remove_children      = false
}

data "vsphere_virtual_machine" "templates" {
  for_each      = local.template_names
  name          = each.value
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "template" {
  for_each      = local.template_networks
  name          = each.value
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "from_template" {
  for_each = var.template_deployments

  name             = each.value.vm_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = each.value.folder

  num_cpus  = each.value.cpu
  memory    = each.value.memory_mb
  guest_id  = data.vsphere_virtual_machine.templates[each.value.template_name].guest_id
  firmware  = data.vsphere_virtual_machine.templates[each.value.template_name].firmware
  scsi_type = data.vsphere_virtual_machine.templates[each.value.template_name].scsi_type

  network_interface {
    network_id   = data.vsphere_network.template[each.value.network_name].id
    adapter_type = var.network_adapter_type
  }

  disk {
    label            = "disk0"
    size             = each.value.disk_gb
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.templates[each.value.template_name].id

    customize {
      linux_options {
        host_name = replace(each.value.vm_name, "_", "-")
        domain    = each.value.domain
      }

      network_interface {
        ipv4_address = each.value.customization_ipv4 ? each.value.static_ipv4_address : null
        ipv4_netmask = each.value.customization_ipv4 ? each.value.static_ipv4_netmask : null
      }

      ipv4_gateway    = each.value.customization_ipv4 ? each.value.ipv4_gateway : null
      dns_server_list = var.dns_servers
    }
  }
}

data "vsphere_network" "ova" {
  for_each      = local.ova_networks
  name          = each.value
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "from_ova" {
  for_each = var.ova_deployments

  name             = each.value.vm_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = each.value.folder

  num_cpus = each.value.cpu
  memory   = each.value.memory_mb

  network_interface {
    network_id   = data.vsphere_network.ova[each.value.network_name].id
    adapter_type = var.network_adapter_type
  }

  ovf_deploy {
    allow_unverified_ssl_cert = var.allow_unverified_ssl
    local_ovf_path            = each.value.local_ovf_path
    disk_provisioning         = each.value.disk_provisioning
    ip_protocol               = each.value.ip_protocol
    ip_allocation_policy      = each.value.ip_allocation_policy
    ovf_network_map = {
      "VM Network" = each.value.network_name
    }
  }
}

data "vsphere_network" "iso" {
  for_each      = local.iso_networks
  name          = each.value
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "from_iso" {
  for_each = var.iso_deployments

  name             = each.value.vm_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = each.value.folder

  num_cpus  = each.value.cpu
  memory    = each.value.memory_mb
  guest_id  = each.value.guest_id
  firmware  = "efi"
  scsi_type = "pvscsi"

  network_interface {
    network_id   = data.vsphere_network.iso[each.value.network_name].id
    adapter_type = var.network_adapter_type
  }

  disk {
    label            = "disk0"
    size             = each.value.disk_gb
    thin_provisioned = true
  }

  cdrom {
    datastore_id = data.vsphere_datastore.datastore.id
    path         = each.value.iso_path
  }
}
