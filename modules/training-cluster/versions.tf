terraform {
  required_providers {


    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.50.0"
    }

    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source                = "hashicorp/kubernetes"
      configuration_aliases = [kubernetes.local]
    }
    local = {
      source = "hashicorp/local"
    }
    template = {
      source = "hashicorp/template"
    }
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    ssh = {
      source = "loafoe/ssh"
    }
  }
  required_version = ">= 1.3.3"
}
