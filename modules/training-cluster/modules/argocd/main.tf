
resource "rancher2_namespace" "argocd-namespace" {

  name       = "argocd"
  project_id = var.rancher_system_project.id

  labels = {
    certificate-labapp = "true"
  }
}

resource "kubernetes_cluster_role" "argocd" {
  metadata {
    name = "argocd"
  }

  rule {
    api_groups = ["argoproj.io"]
    resources  = ["applications"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

# Student Prod Namespaces
resource "rancher2_namespace" "student-namespace-prod" {

  name       = "${var.studentname-prefix}${count.index + 1}-prod"
  project_id = var.rancher_training_project.id

  labels = {
    certificate-labapp = "true"
  }

  count = var.count-students
}


// Allow to use the SA from Webshell Namespace to also access this argocd student prod Namespace
resource "kubernetes_role_binding" "student-prod" {
  metadata {
    name      = "admin-rb"
    namespace = "${var.studentname-prefix}${count.index + 1}-prod"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "webshell"
    namespace = "${var.studentname-prefix}${count.index + 1}"
  }

  count = var.count-students
}

resource "kubernetes_role_binding" "argocd-prod" {
  metadata {
    name      = "argocd-rb"
    namespace = "${var.studentname-prefix}${count.index + 1}-prod"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "argocd"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "webshell"
    namespace = "${var.studentname-prefix}${count.index + 1}"
  }

  count = var.count-students
}

# Student Dev Namespaces
resource "rancher2_namespace" "student-namespace-dev" {

  name       = "${var.studentname-prefix}${count.index + 1}-dev"
  project_id = var.rancher_training_project.id

  labels = {
    certificate-labapp = "true"
  }

  count = var.count-students
}


// Allow to use the SA from Webshell Namespace to also access this argocd student prod Namespace
resource "kubernetes_role_binding" "student-dev" {
  metadata {
    name      = "admin-rb"
    namespace = "${var.studentname-prefix}${count.index + 1}-dev"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "webshell"
    namespace = "${var.studentname-prefix}${count.index + 1}"
  }

  count = var.count-students
}

resource "kubernetes_role_binding" "argocd-dev" {
  metadata {
    name      = "argocd-rb"
    namespace = "${var.studentname-prefix}${count.index + 1}-dev"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "argocd"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "webshell"
    namespace = "${var.studentname-prefix}${count.index + 1}"
  }

  count = var.count-students
}


# Student  Namespaces
resource "kubernetes_role_binding" "argocd" {
  metadata {
    name      = "argocd-rb"
    namespace = "${var.studentname-prefix}${count.index + 1}"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "argocd"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "webshell"
    namespace = "${var.studentname-prefix}${count.index + 1}"
  }

  count = var.count-students
}

// Allow access to argocd resrouces in argocd namespace
resource "kubernetes_role_binding" "argocd-app" {
  metadata {
    name      = "argocd-app-rb"
    namespace = rancher2_namespace.argocd-namespace.name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "argocd"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "webshell"
    namespace = "${var.studentname-prefix}${count.index + 1}"
  }

  count = var.count-students
}

# Secret was auto-generated by the helm chart, retriev this for output
data "kubernetes_secret" "admin-secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = rancher2_namespace.argocd-namespace.name
  }

  depends_on = [
    helm_release.argocd
  ]
}


resource "helm_release" "argocd" {


  name       = "argocd"
  repository = var.chart-repository
  chart      = "argo-cd"
  namespace  = rancher2_namespace.argocd-namespace.name


  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  set {
    name  = "server.config.url"
    value = "https://argocd.labapp.acend.ch"
  }

  set {
    name  = "server.metrics.enabled"
    value = "true"
  }

  set {
    name  = "server.ingress.enabled"
    value = "true"
  }

  set {
    name  = "server.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/backend-protocol"
    value = "HTTPS"
  }

  set {
    name  = "server.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/force-ssl-redirect"
    value = "true"
  }

  set {
    name  = "server.ingress.hosts[0]"
    value = "argocd.labapp.acend.ch"
  }

  set {
    name  = "server.ingress.tls[0].hosts[0]"
    value = "argocd.labapp.acend.ch"
  }

  set {
    name  = "server.ingress.tls[0].secretName"
    value = "labapp-wildcard"
  }

  set {
    name  = "server.ingress.https"
    value = "true"
  }

  set {
    name  = "server.ingressGrpc.enabled"
    value = "true"
  }

  set {
    name  = "server.ingressGrpc.annotations.nginx\\.ingress\\.kubernetes\\.io/backend-protocol"
    value = "GRPC"
  }

  set {
    name  = "server.ingressGrpc.hosts[0]"
    value = "argocd-grpc.labapp.acend.ch"
  }

  set {
    name  = "server.ingressGrpc.tls[0].hosts[0]"
    value = "argocd-grpc.labapp.acend.ch"
  }

  set {
    name  = "server.ingressGrpc.tls[0].secretName"
    value = "labapp-wildcard"
  }

  set {
    name  = "server.ingressGrpc.https"
    value = "true"
  }

  values = [
    templatefile("${path.module}/manifests/values_account_student.yaml", { studentname-prefix = var.studentname-prefix, count-students = var.count-students, passwords = var.student-passwords }),
    templatefile("${path.module}/manifests/values_rbacConfig_policy.yaml", { studentname-prefix = var.studentname-prefix, count-students = var.count-students }),
    templatefile("${path.module}/manifests/values_projects.yaml", { studentname-prefix = var.studentname-prefix, count-students = var.count-students }),
  ]

}
