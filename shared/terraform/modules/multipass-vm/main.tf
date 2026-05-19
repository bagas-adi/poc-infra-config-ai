terraform {
  required_providers {
    multipass = {
      source  = "larstobi/multipass"
      version = "~> 1.4"
    }
  }
}

resource "multipass_instance" "vm" {
  name   = var.name
  cpus   = var.cpus
  memory = var.memory
  disk   = var.disk
  image  = var.image

  cloudinit_file = var.cloudinit_file != "" ? var.cloudinit_file : null
}
