output "vm_name" {
  description = "Name of the PostgreSQL VM"
  value       = module.vm.name
}

output "vm_ipv4" {
  description = "IPv4 address of the PostgreSQL VM"
  value       = module.vm.ipv4
}
