# Deploy Cert-Manager for Certificates

resource "kubernetes_namespace" "cert-manager" {
  depends_on = [
    time_sleep.wait_for_cluster_ready
  ]
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "certmanager" {
  name       = "certmanager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.12.2"
  namespace  = kubernetes_namespace.cert-manager.metadata[0].name

  set {
    name  = "installCRDs"
    value = true
  }

  set {
    name  = "ingressShim.defaultIssuerName"
    value = "letsencrypt-prod"
  }

  set {
    name  = "ingressShim.defaultIssuerKind"
    value = "ClusterIssuer"
  }

  set {
    name  = "dns01RecursiveNameservers"
    value = "8.8.8.8:53"
  }

  set {
    name  = "dns01RecursiveNameserversOnly"
    value = true
  }

}

resource "helm_release" "certmanager-webhook-hosttech" {

  depends_on = [
    helm_release.certmanager
  ]

  name       = "cert-manager-webhook-hosttech"
  repository = "https://piccobit.github.io/helm-charts"
  chart      = "cert-manager-webhook-hosttech"
  version    = "0.3.0"
  namespace  = kubernetes_namespace.cert-manager.metadata[0].name

  set {
    name  = "groupName"
    value = "acme.acend.ch"
  }

  set {
    name  = "certManager.serviceAccountName"
    value = "certmanager-cert-manager"
  }

}



# For Secret/Certificate sync across Namespaces
resource "helm_release" "kubed" {

  depends_on = [
    time_sleep.wait_for_cluster_ready
  ]

  name       = "config-syncer"
  repository = "https://charts.appscode.com/stable/"
  chart      = "config-syncer"
  version    = "v0.14.0-rc.0"
  namespace  = "kube-system"

}

resource "k8s_cert_manager_io_cluster_issuer_v1" "clusterissuer-letsencrypt-prod" {

  provider = metio-k8s

  depends_on = [
    helm_release.certmanager
  ]

  metadata = {
    name = "letsencrypt-prod"
  }

  spec = {
    acme = {
      email = "${var.letsencrypt_email}"
      private_key_secret_ref = {
        name = "letsencrypt-prod"
      }
      server = "https://acme-v02.api.letsencrypt.org/directory"
      solvers = [{
        http01 = {
          ingress = {
            class = "haproxy"
          }
        }
      }]
    }
  }
}

resource "k8s_manifest" "clusterissuer-letsencrypt-prod" {
  provider = banzaicloud-k8s
  content  = k8s_cert_manager_io_cluster_issuer_v1.clusterissuer-letsencrypt-prod.yaml
}

resource "k8s_cert_manager_io_cluster_issuer_v1" "clusterissuer-acend-hosttech" {
  provider = metio-k8s

  depends_on = [
    helm_release.certmanager
  ]

  metadata = {
    name = "letsencrypt-prod-acend"
  }

  spec = {
    acme = {
      email = var.letsencrypt_email
      private_key_secret_ref = {
        name = "letsencrypt-prod-acend"
      }
      server = "https://acme-v02.api.letsencrypt.org/directory"
      solvers = [{
        selector = {
          dnsNames = [
            "*.${var.cluster_name}.${split(".", var.cluster_domain)[0]}.acend.ch"
          ]
        }
        dns01 = {
          webhook = {
            group_name  = "acme.acend.ch"
            solver_name = "hosttech"
            config = {
              secretName = "hosttech-secret"
              apiUrl     = "https://api.ns1.hosttech.eu/api/user/v1"
            }
          }
        }
      }]
    }
  }
}

resource "k8s_manifest" "clusterissuer-acend-hosttech" {
  provider = banzaicloud-k8s
  content  = k8s_cert_manager_io_cluster_issuer_v1.clusterissuer-acend-hosttech.yaml
}

resource "k8s_cert_manager_io_certificate_v1" "certificate-acend-wildcard" {
  provider = metio-k8s

  depends_on = [
    helm_release.certmanager
  ]

  metadata = {
    name      = "acend-wildcard"
    namespace = kubernetes_namespace.cert-manager.metadata[0].name
  }


  spec = {
    dns_names = [
      "*.${var.cluster_name}.${split(".", var.cluster_domain)[0]}.acend.ch"
    ]
    issuer_ref = {
      kind = "ClusterIssuer"
      name = "letsencrypt-prod-acend"
    }
    secret_name = "acend-wildcard"
    secret_template = {
      annotations = {
        "kubed.appscode.com/sync" = "certificate-wildcard=true"
      }
    }
  }
}

resource "k8s_manifest" "certificate-acend-wildcard" {
  provider = banzaicloud-k8s
  content  = k8s_cert_manager_io_certificate_v1.certificate-acend-wildcard.yaml
}

resource "kubernetes_secret" "hosttech-secret" {

  metadata {
    name      = "hosttech-secret"
    namespace = kubernetes_namespace.cert-manager.metadata[0].name
  }

  data = {
    token = var.hosttech_dns_token
  }

}



data "kubernetes_secret" "acend-wildcard" {

  metadata {
    name      = "acend-wildcard"
    namespace = kubernetes_namespace.cert-manager.metadata[0].name
  }

}

resource "time_sleep" "wait_for_ssl_ready" {
  // Wait for the acend-wildcard to be ready before we can use resources like gitea.
  depends_on = [data.kubernetes_secret.acend-wildcard]

  create_duration = "30s"
}