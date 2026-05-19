variable "vm_name" {
  description = "Name of the PostgreSQL VM"
  type        = string
  default     = "postgresql"
}

variable "cpus" {
  description = "Number of CPUs"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory allocation"
  type        = string
  default     = "2G"
}

variable "disk" {
  description = "Disk size"
  type        = string
  default     = "10G"
}

variable "image" {
  description = "Ubuntu image"
  type        = string
  default     = "22.04"
}
