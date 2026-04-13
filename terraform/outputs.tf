output "tower_vm_names" {
  description = "Tower/Controller VM names"
  value       = { for key, vm in vsphere_virtual_machine.tower_vms : key => vm.name }
}

output "tower_vm_ips" {
  description = "Detected Tower/Controller VM addresses"
  value       = { for key, vm in vsphere_virtual_machine.tower_vms : key => vm.default_ip_address }
}

output "managed_linux_vm_names" {
  description = "Managed Linux VM names"
  value       = { for key, vm in vsphere_virtual_machine.managed_linux_vms : key => vm.name }
}

output "managed_linux_vm_ips" {
  description = "Detected managed Linux VM addresses"
  value       = { for key, vm in vsphere_virtual_machine.managed_linux_vms : key => vm.default_ip_address }
}
