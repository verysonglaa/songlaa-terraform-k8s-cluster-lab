resource "kubernetes_namespace" "ingress-haproxy" {

  depends_on = [
    time_sleep.wait_for_cluster_ready
  ]
  metadata {
    name = "ingress-haproxy"
  }
}
resource "helm_release" "ingress-haproxy" {

  name       = "ingress-haproxy"
  repository = "https://haproxytech.github.io/helm-charts"
  chart      = "kubernetes-ingress"
  version    = "1.30.5"
  namespace  = kubernetes_namespace.ingress-haproxy.metadata[0].name

  set {
    name  = "controller.replicaCount"
    value = "2"
  }

  set {
    name  = "controller.ingressClassResource.default"
    value = "true"
  }


  set {
    name  = "controller.defaultTLSSecret.secret"
    value = "acend-wildcard"
  }

  set {
    name  = "controller.defaultTLSSecret.secretNamespace"
    value = "cert-manager"
  }

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

}

data "kubernetes_service" "ingress-haproxy" {

  depends_on = [
    helm_release.ingress-haproxy
  ]
  metadata {
    name      = "ingress-haproxy-kubernetes-ingress"
    namespace = kubernetes_namespace.ingress-haproxy.metadata[0].name
  }

}


