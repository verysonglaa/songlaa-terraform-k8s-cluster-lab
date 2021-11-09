resource "rancher2_namespace" "student-namespace" {

  name       = var.student-name
  project_id = var.rancher_training_project.id

  labels = {
      certificate-labapp = "true" # this will copy the wildcard cert created with cert-manager using the kubed installation
  }
}

resource "rancher2_namespace" "student-namespace-quotalab" {

  name       = "${var.student-name}-quota"
  project_id = var.rancher_quotalab_project.id

}

// Allow to use the SA from Webshell Namespace to also access this argocd student prod Namespace
resource "kubernetes_role_binding" "student-quotalab" {
  metadata {
    name      = "admin-rb"
    namespace = rancher2_namespace.student-namespace-quotalab.name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "webshell"
    namespace = var.student-name
  }

}

resource "helm_release" "webshell" {


  name       = "webshell"
  chart      = var.chart-repository
  namespace  = rancher2_namespace.student-namespace.name

  set {
    name  = "student"
    value = var.student-name
  }

  set {
    name = "password"
    value = var.student-password
  }

  set {
    name = "ingress.enabled"
    value = "true"
  }

  set {
    name = "ingress.className"
    value = "nginx"
  }

  set {
    name  = "ingress.annotations.ingress\\.kubernetes\\.io/ssl-redirect"
    value = "true"
    type  = "string"
  }

  set {
    name = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-type"
    value = "basic"
  }

  set {
    name = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-secret"
    value = "basic-auth"
  }

  set {
    name = "ingress.hosts[0].host"
    value = "${var.student-name}.${var.domain}"
  }

  set {
    name = "ingress.hosts[0].paths[0].path"
    value = "/"
  }

  set {
    name = "ingress.hosts[0].paths[0].pathType"
    value = "ImplementationSpecific"
  }

  set {
    name = "ingress.tls[0].secretName"
    value = "labapp-wildcard"
  }

  set {
    name = "ingress.tls[0].hosts[0]"
    value = "${var.student-name}.${var.domain}"
  }


}
