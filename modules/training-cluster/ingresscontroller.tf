resource "kubernetes_namespace" "ingress-nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress-nginx" {

  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.5.2"
  namespace  = kubernetes_namespace.ingress-nginx.metadata[0].name

  set {
    name  = "controller.replicaCount"
    value = "2"
  }

  set {
    name  = "controller.ingressClassResource.default"
    value = true
  }

  set {
    name = "controller.extraArgs.default-ssl-certificate"
    value = "cert-manager/acend-wildcard"
  }

}

data "kubernetes_service" "ingress-nginx" {

  depends_on = [
    helm_release.ingress-nginx
  ]
  metadata {
    name      = "ingress-nginx-controller"
    namespace = kubernetes_namespace.ingress-nginx.metadata[0].name
  }

}