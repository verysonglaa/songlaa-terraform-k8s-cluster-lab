#!/bin/bash

read -p "This will update/create a VM. Are you sure? (y/N): " -n1 confirmation

if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
    echo "Operation canceled."
    exit 1
fi

terraform apply -auto-approve --var-file prod.tfvars
# Get the IP address from the Terraform output

#current script directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")

for i in {0..1}; do

    user="user"$((i+1))
    echo $i
    terraform output -json ssh_keys | jq -r .[$i].private_key_openssh  > $user.pem && chmod 600 $user.pem
    echo "ssh -o IdentitiesOnly=yes -i $SCRIPT_DIR/$user.pem $user@$(terraform output -json ips | jq -r .[$i]) "
    echo "or with thinkpad key:"
    echo "ssh -i ~/.ssh/id_rsa root@$(terraform output -json ips | jq -r .[$i]) "
    echo "Pw auth if enabled (troubleshooting):"
    echo "Password: $(terraform output -json passwords | jq -r .[$i])"
done

echo "Attention: It looks like wsl or vscode is messing up the file permissions. Try inside docker container (cp .pem file)"


