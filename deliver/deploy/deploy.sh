#!/bin/bash
read -p "This will update/create a new cluster. Are you sure? (y/N): " -n1 confirmation

if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
    echo "Operation canceled."
    exit 1
fi



for i in {0..3}; do

    user="user"$((i+1))
    echo $i
    terraform output -json student-vm-ssh-keys | jq -r .[$i].private_key_openssh 
    echo "ssh -i $user.pem $user@$(terraform output -json student-vm-ips | jq -r .[$i]) "
done


terraform apply -auto-approve --var-file prod.tfvars
terraform output --raw training-kubeconfig > ~/.kube/training-cluster-config
echo
echo "export KUBECONFIG=~/.kube/training-cluster-config"
echo "kubectl -n welcome port-forward services/welcome 8080:80 &"
sleep 15
echo "curl http://localhost:8080/teacher"
echo
echo "access argocd under https://argocd.training.cluster.songlaa.com"
echo "username: admin"
echo "password: $(terraform output argocd-admin-password)"