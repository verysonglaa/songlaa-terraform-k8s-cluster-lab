output "kubeconfig_raw" {
  value = local.kubeconfig_raw
}

# output "webshell-links" {
#   value = "%{for link in module.webshell.*.student-direct-webshelllink}${link}  \n%{endfor}"
# }

output "argocd-admin-username" {
  value = "admin"
}

output "argocd-admin-password" {
  value = data.kubernetes_secret.argocd-admin-secret.data.password
}

output "argocd-url" {
  value = "https://argocd.${var.cluster_name}.${var.cluster_domain}"
}

output "gitea-admin-password" {
  value = var.gitea-enabled ? module.gitea[0].admin-password : ""
}

output "gitea-admin-username" {
  value = var.gitea-enabled ? module.gitea[0].admin-username : ""
}

output "gitea-url" {
  value = var.gitea-enabled ? module.gitea[0].gitea-url : ""
}

output "student-vm-ip-address" {
  value = var.user-vms-enabled ? module.student-vms[0].ip-address : []
}

output "student-vm-ipv6-address" {
  value = var.user-vms-enabled ? module.student-vms[0].ipv6-address : []
}