read -p "WARNING! Are you sure you want to DESTROY this cluster? Please make sure kubeconfig points to the right cluster! (y/N): " -n1 confirmation

if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
    echo "Operation canceled."
    exit 1
fi

#backup certs for ingress

export KUBECONFIG=~/.kube/training-cluster-config

kubectl -n cert-manager get secret letsencrypt-prod -o yaml   > letsencrypt-prod.yaml


kubectl patch applications.argoproj.io applications -n argocd --type merge -p '{"spec": {"syncPolicy": {"automated": null}}}'  
kubectl -n argocd delete application haproxy-ingress  
kubectl -n argocd delete application applications   
kubectl delete ns ingress-haproxy --ignore-not-found=true  

# Wait for DNS Record to be cleaned up
sleep 120
kubectl -n argocd delete applicationsets --all   || true
kubectl -n argocd delete application --all   || true

kubectl delete  validatingwebhookconfigurations.admissionregistration.k8s.io kyverno-resource-validating-webhook-cfg --ignore-not-found=true
kubectl delete  validatingwebhookconfigurations.admissionregistration.k8s.io kyverno-policy-validating-webhook-cfg --ignore-not-found=true


echo "Destroying cluster with terraform"

terraform destroy --auto-approve --var-file prod.tfvars

#destroyin mostly fails because of kyverno webhook, just do it again
kubectl delete  validatingwebhookconfigurations.admissionregistration.k8s.io kyverno-resource-validating-webhook-cfg --ignore-not-found=true
kubectl delete  validatingwebhookconfigurations.admissionregistration.k8s.io kyverno-policy-validating-webhook-cfg --ignore-not-found=true


echo "Destroying cluster with terraform"

kubectl -n cert-manager delete pods --all --force --grace-period=0

terraform destroy --auto-approve --var-file prod.tfvars