#!/bin/bash

read -p "This will update/create a VM. Are you sure? (y/N): " -n1 confirmation

if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
    echo "Operation canceled."
    exit 1
fi

terraform apply -auto-approve --var-file prod.tfvars
# Get the IP address from the Terraform output


for i in {0..1}; do

    user="user"$((i+1))
    echo $i
    terraform output -json ssh_keys | jq -r .[$i].private_key_openssh  > $user.pem && chmod 600 $user.pem
    echo "ssh -i $user.pem $user@$(terraform output -json ips | jq -r .[$i]) "
done




