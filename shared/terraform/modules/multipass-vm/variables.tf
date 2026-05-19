variable "name" {
  description = "Name of the Multipass VM instance"
  type        = string
}

variable "cpus" {
  description = "Number of CPUs to allocate"
  type        = number
  default     = 1
}

variable "memory" {
  description = "Amount of memory to allocate (e.g. 1G, 2G, 4G)"
  type        = string
  default     = "1G"
}

variable "disk" {
  description = "Disk size to allocate (e.g. 5G, 10G, 20G)"
  type        = string
  default     = "5G"
}

variable "image" {
  description = "Ubuntu image to use for the VM"
  type        = string
  default     = "22.04"
}

variable "cloudinit_file" {
  description = "Path to a cloud-init YAML file for instance bootstrapping"
  type        = string
  default     = ""
}
