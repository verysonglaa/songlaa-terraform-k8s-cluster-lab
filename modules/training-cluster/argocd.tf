
resource "kubernetes_namespace" "argocd" {

  depends_on = [
    time_sleep.wait_for_cluster_ready,
  ]

  metadata {
    name = "argocd"

    labels = {
      certificate-wildcard          = "true"
      "kubernetes.io/metadata.name" = "argocd"
    }
  }
}

resource "kubernetes_cluster_role" "argocd" {

  depends_on = [
    time_sleep.wait_for_cluster_ready,
  ]

  metadata {
    name = "argocd"
  }

  rule {
    api_groups = ["argoproj.io"]
    resources  = ["applications", "applicationset"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

# Secret was auto-generated by the helm chart, retriev this for output

resource "random_password" "argocd-admin-password" {
  length           = 16
  special          = true
  override_special = "_%@"
}


resource "helm_release" "argocd" {

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata.0.name
  version    = "5.37.1"


  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  set {
    name  = "server.config.kustomize\\.buildOptions"
    value = "--enable-helm"
  }




  set {
    name  = "configs.cm.url"
    value = "https://argocd.${var.cluster_name}.${var.cluster_domain}"
  }

  set {
    name  = "configs.cm.params.server.insecure"
    value = "true"
  }

  set {
    name  = "configs.secret.argocdServerAdminPassword"
    value = random_password.argocd-admin-password.bcrypt_hash
  }

  set {
    name  = "server.ingress.enabled"
    value = "true"
  }

  set {
    name  = "server.ingress.annotations.ingress\\.kubernetes\\.io/server-ssl"
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
    name  = "server.ingressGrpc.enabled"
    value = "true"
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

  values = [
    templatefile("${path.module}/manifests/argocd/values_account_student.yaml", { studentname-prefix = var.studentname-prefix, count-students = var.count-students, passwords = random_password.student-passwords }),
    templatefile("${path.module}/manifests/argocd/values_rbacConfig_policy.yaml", { studentname-prefix = var.studentname-prefix, count-students = var.count-students }),
    templatefile("${path.module}/manifests/argocd/values_resource-exclude.yaml", {}),
  ]

}

resource "helm_release" "argocd-training-project" {

  depends_on = [
    helm_release.argocd
  ]

  name       = "argocd-apps"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  namespace  = kubernetes_namespace.argocd.metadata.0.name
  version    = "1.2.0"


  values = [
    templatefile("${path.module}/manifests/argocd/values_projects.yaml", { studentname-prefix = var.studentname-prefix, count-students = var.count-students }),
  ]

}

resource "null_resource" "cleanup-argo-cr-before-destroy" {

  triggers = {
    kubeconfig = base64encode(local.kubeconfig_raw)

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

resource "helm_release" "argocd-bootstrap" {

  depends_on = [
    helm_release.argocd
  ]

  name       = "argocd-bootstrap"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  namespace  = kubernetes_namespace.argocd.metadata.0.name
  version    = "1.2.0"

  values = [
    templatefile("${path.module}/manifests/argocd/argocd-bootstrap-values.yaml", {
      namespace = helm_release.argocd.namespace
    }),
  ]
}
