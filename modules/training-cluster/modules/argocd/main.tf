
resource "kubernetes_namespace" "argocd" {

  metadata {
    name = "argocd"

    labels = {
      certificate-wildcard            = "true"
      "kubernetes.io/metadata.name" = "argocd"
    }
  }
}

resource "kubernetes_cluster_role" "argocd" {
  metadata {
    name = "argocd"
  }

  rule {
    api_groups = ["argoproj.io"]
    resources  = ["applications", "applicationset"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

# Student Prod Namespaces
resource "kubernetes_namespace" "student-namespace-prod" {

  metadata {
    name = "${var.studentname-prefix}${count.index + 1}-prod"

    labels = {
      certificate-wildcard          = "true"
      "kubernetes.io/metadata.name" = "${var.studentname-prefix}${count.index + 1}-prod"
    }
  }

  count = var.count-students
}


// Allow to use the SA from Webshell Namespace to also access this argocd student prod Namespace
resource "kubernetes_role_binding" "student-prod" {


  metadata {
    name      = "admin-rb"
    namespace = kubernetes_namespace.student-namespace-prod[count.index].metadata.0.name
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
    namespace = kubernetes_namespace.student-namespace-prod[count.index].metadata.0.name
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
resource "kubernetes_namespace" "student-namespace-dev" {

  metadata {
    name = "${var.studentname-prefix}${count.index + 1}-dev"

    labels = {
      certificate-labapp            = "true"
      "kubernetes.io/metadata.name" = "${var.studentname-prefix}${count.index + 1}-dev"
    }
  }


  count = var.count-students
}


// Allow to use the SA from Webshell Namespace to also access this argocd student prod Namespace
resource "kubernetes_role_binding" "student-dev" {
  metadata {
    name      = "admin-rb"
    namespace = kubernetes_namespace.student-namespace-dev[count.index].metadata.0.name
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
    namespace = kubernetes_namespace.student-namespace-dev[count.index].metadata.0.name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.argocd.metadata[0].name
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
    name      = kubernetes_cluster_role.argocd.metadata[0].name
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
    name      = "argocd-app-${var.studentname-prefix}${count.index + 1}-rb"
    namespace = kubernetes_namespace.argocd.metadata.0.name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.argocd.metadata[0].name
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
    namespace = kubernetes_namespace.argocd.metadata.0.name
  }

  depends_on = [
    helm_release.argocd
  ]
}


resource "helm_release" "argocd" {


  name       = "argocd"
  repository = var.chart-repository
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata.0.name
  version    = var.chart-version


  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  set {
    name  = "server.config.url"
    value = "https://argocd.${var.cluster_name}.${var.cluster_domain}"
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
    value = "argocd.${var.cluster_name}.${var.cluster_domain}"
  }

  set {
    name  = "server.ingress.tls[0].hosts[0]"
    value = "argocd.${var.cluster_name}.${var.cluster_domain}"
  }

  set {
    name  = "server.ingress.tls[0].secretName"
    value = "acend-wildcard"
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
    value = "argocd-grpc.${var.cluster_name}.${var.cluster_domain}"
  }

  set {
    name  = "server.ingressGrpc.tls[0].hosts[0]"
    value = "argocd-grpc.${var.cluster_name}.${var.cluster_domain}"
  }

  set {
    name  = "server.ingressGrpc.tls[0].secretName"
    value = "acend-wildcard"
  }

  set {
    name  = "server.ingressGrpc.https"
    value = "true"
  }

  values = [
    templatefile("${path.module}/manifests/values_account_student.yaml", { studentname-prefix = var.studentname-prefix, count-students = var.count-students, passwords = var.student-passwords }),
    templatefile("${path.module}/manifests/values_rbacConfig_policy.yaml", { studentname-prefix = var.studentname-prefix, count-students = var.count-students }),
    templatefile("${path.module}/manifests/values_projects.yaml", { studentname-prefix = var.studentname-prefix, count-students = var.count-students }),
    templatefile("${path.module}/manifests/values_resource-exclude.yaml", {}),
  ]

}

resource "null_resource" "cleanup-argo-cr-before-destroy" {

  triggers = {
    kubeconfig = base64encode(var.kubeconfig_raw)

  }
  provisioner "local-exec" {
    when        = destroy
    command     = <<EOH
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
chmod +x ./kubectl

./kubectl delete application,applicationset -A --all --kubeconfig <(echo $KUBECONFIG | base64 --decode) || true
EOH
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }

  depends_on = [
    helm_release.argocd
  ]

}
