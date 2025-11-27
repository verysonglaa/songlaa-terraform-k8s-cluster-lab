#!/bin/bash
read -p "This will update/create a new cluster. Are you sure? (y/N): " -n1 confirmation

if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
    echo "Operation canceled."
    exit 1
fi


terraform apply -auto-approve --var-file prod.tfvars
terraform output --raw training-kubeconfig > ~/.kube/training-cluster-config

echo "Done, wait 2 minutes for the cluster to be ready"
sleep 120

echo "find output data for ssh connections for students in .ssh-connection.txt"
echo "find e-mail templates in .email-templates.txt"


#./scripts-4-student-communication/create-linklist.sh

echo "generate e-mail templates for students:"
./scripts-4-student-communication/create-user-info.sh

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