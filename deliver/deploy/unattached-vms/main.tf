

provider "hcloud" {
  token = var.hcloud_api_token
}

variable "count-students" {
  type    = number
  default = 0
}

variable "hcloud_api_token" {
  type      = string
  sensitive = true
}

variable "studentname-prefix" {
  type    = string
  default = "user"
}

variable "enable_password_login" {
  type    = bool
  default = false
  description = "Enable password login for VMs (useful for troubleshooting)"
}


resource "random_password" "student-passwords" {
  length           = 16
  special          = true
  override_special = ".-_"

  count = var.count-students
}



resource "tls_private_key" "terraform" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "hcloud_ssh_key" "terraform" {
  name       = "terraform-unattached"
  public_key = tls_private_key.terraform.public_key_openssh
}


### Start VM Deploy
###############################

module "student-vms-unattached" {
  source = "../../../modules/training-cluster/modules/student-vms"

  count-students        = var.count-students
  student-passwords     = random_password.student-passwords
  studentname-prefix    = var.studentname-prefix
  enable_password_login = var.enable_password_login

  #count = var.count-students
  cluster_name = "unattached"

}

output "ips" {
  value = module.student-vms-unattached.ip-address
}

output "ssh_keys" {
  value     = module.student-vms-unattached.user-ssh-keys
  sensitive = true
}

output "passwords" {
  value     = module.student-vms-unattached.student-passwords
  sensitive = true
}