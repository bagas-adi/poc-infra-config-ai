terraform {
  required_providers {
    multipass = {
      source  = "larstobi/multipass"
      version = "~> 1.4"
    }
  }
}

provider "multipass" {}

module "vm" {
  source = "../../shared/terraform/modules/multipass-vm"

  name   = var.vm_name
  cpus   = var.cpus
  memory = var.memory
  disk   = var.disk
  image  = var.image
}
