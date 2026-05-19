#!/bin/bash
read -p "This will update/create a new cluster. Are you sure? (y/N): " -n1 confirmation

if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
    echo "Operation canceled."
    exit 1
fi


terraform apply -auto-approve --var-file prod.tfvars
# continue if terraform apply was successful
if [ $? -ne 0 ]; then
    echo "Terraform apply failed. Exiting."
    exit 1
fi

terraform output --raw training-kubeconfig > ~/.kube/training-cluster-config

echo "Done, wait 2 minutes for the cluster to be ready"
sleep 180


#./scripts-4-student-communication/create-linklist.sh

export KUBECONFIG=~/.kube/training-cluster-config
echo "generate e-mail templates for students:"
KUBECONFIG=~/.kube/training-cluster-config ./scripts-4-student-communication/create-user-info.sh
echo "find e-mail templates in current_instance/.email-templates.txt"

echo "---------------------------------"

echo "export KUBECONFIG=~/.kube/training-cluster-config"
echo "kubectl -n welcome port-forward services/welcome 8080:80 &"
sleep 15
echo "curl http://localhost:8080/teacher"
echo
echo "access argocd under https://argocd.training.cluster.songlaa.com"
echo "username: admin"
echo "password: $(terraform output argocd-admin-password)"

echo "kubernetes dashboard: https://dashboard.training.cluster.songlaa.com"