
provider "cloudflare" { # using tf env vars
  api_token = var.cloudflare_api_token
}

// "K8S API for Training Cluster ${var.cluster_name}"
resource "cloudflare_record" "api_a_record" {
  zone_id = var.cloudflare_zone_id
  name    = "api.${var.cluster_name}.${split(".", var.cluster_domain)[0]}"
  content = hcloud_load_balancer.lb.ipv4
  type    = "A"
  ttl     = 3600
  proxied = false
}

// "K8S API for Training Cluster ${var.cluster_name}"

resource "cloudflare_record" "api_aaaa_record" {
  zone_id = var.cloudflare_zone_id
  name    = "api.${var.cluster_name}.${split(".", var.cluster_domain)[0]}"
  content = hcloud_load_balancer.lb.ipv6
  type    = "AAAA"
  ttl     = 3600
  proxied = false
}



resource "kubernetes_namespace" "cert_manager" {

  provider = kubernetes.local

  depends_on = [
    ssh_resource.getkubeconfig
  ]
  metadata {
    name = "cert-manager"
  }
}

# use kubernetes provider to create a secret in namespace cert-manager named cloudflare-api-token-secret which holds a token named api-token and put var.cloudflare_api_token in it
resource "kubernetes_secret" "cloudflare_api_token_secret" {

  provider = kubernetes.local
  metadata {
    name      = "cloudflare-api-token-secret"
    namespace = kubernetes_namespace.cert_manager.metadata.0.name
  }
  data = {
    api-token = var.cloudflare_api_token
  }
}

