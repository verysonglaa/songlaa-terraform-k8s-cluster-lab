#!/bin/bash
read -p "Are you sure? (y/N): " -n1 confirmation

if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
    echo "Operation canceled."
    exit 1
fi

terraform apply -auto-approve --var-file prod.tfvars
terraform output --raw training-kubeconfig > ~/.kube/training-cluster-config
echo
echo "export KUBECONFIG=~/.kube/training-cluster-config"
echo "kubectl -n welcome port-forward services/welcome 8080:80 &"
echo "curl http://localhost:8080/teacher"

