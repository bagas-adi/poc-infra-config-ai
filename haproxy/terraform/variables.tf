variable "vm_name" {
  description = "Name of the HAProxy VM"
  type        = string
  default     = "haproxy"
}

variable "cpus" {
  description = "Number of CPUs"
  type        = number
  default     = 1
}

variable "memory" {
  description = "Memory allocation"
  type        = string
  default     = "1G"
}

variable "disk" {
  description = "Disk size"
  type        = string
  default     = "5G"
}

variable "image" {
  description = "Ubuntu image"
  type        = string
  default     = "22.04"
}
