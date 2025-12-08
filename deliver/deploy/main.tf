
locals {
  ssh_keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDKFBBA/MsuVxoXTw78/HOa7rFCI7ble5NDPKoZZK8d2CQ2C3pIQcOKyCgZXoAK4/NtDmra2gR1WHC5nltTwgvoH0Yo2axLPnSVFedWsPs1NFMaJnauAeJruEpfKBrmFTZgJ7XG1iMsdisAPBRzQSa7V3tlsaEBCrjV2aHvWxNeOe4ZMAP9bBofFanGs6LL3JOM0c9hCBcsyIxULZNgYr4vaGytPSFV9xjx+k6WmZDuBiw4fFIBfKbdd2RzX5zqmB31kHWAwSSBtJXv7XhfEQYdtzel5rmn/mSoLSrbS4HlDEYou2SVrfH81wa1EFpQqY1ImD79iWezYaFKmb/dLdZzFiz8kshxf4ejfry5FPvUJtdmlJm7OpuiAQxxj3CyKDRe2W4IHev8ulx9DKjLInOabr4Vp99Wb6irwvRUT/HAdxosqImJmIZ5KTkUhSpg8QV6VClZ3Sycebos4pysSp2lGuhisMjenQme7XCgCJes6rXm645DDyaJ0IN2TXoEzK0= gabriel"
  ]
}

provider "hcloud" {
  token = var.hcloud_api_token
}



### Start Training Cluster flavor k8s
###############################

module "training-cluster" {

  providers = {
    hcloud = hcloud
  }

  source = "../../modules/training-cluster"

  cluster_name         = "training"
  cluster_domain       = "cluster.songlaa.com"
  worker_count         = var.worker_count // A minimum of 3 nodes is required use 1 per 3 students with cpx31
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id   = var.cloudflare_zone_id
  hcloud_api_token     = var.hcloud_api_token


  # SSH Public keys deployed on the VM's for SSH access
  extra_ssh_keys = local.ssh_keys

  cluster_admin = ["user1"]

  location    = var.location
  networkzone = var.networkzone # must be compatible with the location (ap-southeast for sin )

  # Webshell
  # Make sure to scale down to 0 before removing the cluster, 
  # otherwise there will be terraform errors due to missing provider config
  count-students = var.count-students

  # User VMs
  user-vms-enabled            = var.user-vms-enabled
  user-vms-unattached-enabled = var.user-vms-unattached-enabled
  user-vms-unattached-count   = var.user-vms-unattached-count


  # RBAC in Webshell
  webshell-rbac-enabled = true

  webshell-settings = {
    version                   = "0.5.19"
    dind-enabled              = var.dind-enabled
    dind-image-tag            = "29.0.1-dind${var.dind-rootless ? "-rootless" : ""}"
    dind-rootless             = var.dind-rootless
    theia-persistence-enabled = true
    dind-persistence-enabled  = true
    webshell-rbac-enabled     = true

    dind_resources = {
      limits = {
        cpu    = "2"
        memory = "1Gi"
      }

      requests = {
        cpu    = "50m"
        memory = "100Mi"
      }
    }
    theia_resources = {
      requests = {
        cpu    = "500m"
        memory = "1Gi"
      }
    }
  }
}

output "training-kubeconfig" {
  value     = module.training-cluster.kubeconfig_raw
  sensitive = true
}

output "argocd-admin-password" {
  value     = module.training-cluster.argocd-admin-password
  sensitive = true
}

output "student-passwords" {
  value     = module.training-cluster.student-passwords
  sensitive = true
}

output "count-students" {
  value = module.training-cluster.count-students
}

output "studentname-prefix" {
  value = module.training-cluster.studentname-prefix
}


output "student-vm-ips" {
  value = module.training-cluster.student-vm-ips
}

output "student-vm-ssh-keys" {
  value     = module.training-cluster.student-vms-ssh_key
  sensitive = true
}


### End Training Cluster flavor k8s