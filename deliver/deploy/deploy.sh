#!/bin/bash
read -p "This will update/create a new cluster. Are you sure? (y/N): " -n1 confirmation

if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
    echo "Operation canceled."
    exit 1
fi


terraform apply -auto-approve --var-file prod.tfvars
terraform output --raw training-kubeconfig > ~/.kube/training-cluster-config

echo "find output data for ssh connections for students in .ssh-connection.txt"

echo "---------------------------------" > .ssh-connection.txt

for i in {0..10}; do

    user="user"$((i+1))
    echo $i >> .ssh-connection.txt
    terraform output -json student-vm-ssh-keys | jq -r .[$i].private_key_openssh >> .ssh-connection.txt
    echo "ssh -i $user.pem $user@$(terraform output -json student-vm-ips | jq -r .[$i]) " >> .ssh-connection.txt
    echo >> .ssh-connection.txt
    echo "token:" >> .ssh-connection.txt
    echo "$(kubectl -n kubernetes-dashboard get secrets read-only-user-token -o jsonpath="{.data.token}" | base64 --decode)" >> .ssh-connection.txt
    echo "---------------------------------" >> .ssh-connection.txt
done

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