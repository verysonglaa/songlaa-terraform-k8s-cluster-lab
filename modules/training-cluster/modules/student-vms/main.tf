resource "tls_private_key" "user-ssh-key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"

  count = var.count-students
}

data "hcloud_ssh_keys" "all" {}

resource "hcloud_server" "user-vm" {
  count = var.count-students

  lifecycle {
    ignore_changes = [
      # Ignore user_data for existing nodes as this requires a replacement
      user_data
    ]
  }

  name        = "vm-${var.cluster_name}-${var.studentname-prefix}-${count.index + 1}"
  location    = var.location
  image       = "ubuntu-22.04"
  server_type = var.node_type

  labels = {
    uservm : "true"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false # disable ipv6 to simplify labs
  }

  # add all ssh keys currently in hetzner to VM root account
  ssh_keys = data.hcloud_ssh_keys.all.ssh_keys[*].id

  user_data = templatefile("${path.module}/manifests/cloudinit.yaml", {
    username    = "${var.studentname-prefix}${count.index + 1}"
    ssh_keys    = [tls_private_key.user-ssh-key[count.index].public_key_openssh]
    password    = var.student-passwords[count.index].bcrypt_hash
    lock_passwd = var.enable_password_login ? "false" : "true"
  })
}

