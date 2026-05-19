output "name" {
  description = "Name of the created Multipass VM"
  value       = multipass_instance.vm.name
}

output "ipv4" {
  description = "IPv4 address of the Multipass VM"
  value       = multipass_instance.vm.ipv4
}
