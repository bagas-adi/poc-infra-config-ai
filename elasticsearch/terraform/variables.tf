variable "vm_name" {
  description = "Name of the Elasticsearch VM"
  type        = string
  default     = "elasticsearch"
}

variable "cpus" {
  description = "Number of CPUs"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory allocation"
  type        = string
  default     = "4G"
}

variable "disk" {
  description = "Disk size"
  type        = string
  default     = "20G"
}

variable "image" {
  description = "Ubuntu image"
  type        = string
  default     = "22.04"
}
