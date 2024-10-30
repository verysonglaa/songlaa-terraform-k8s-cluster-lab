read -p "WARNING! Are you sure you want to DESTROY this cluster? Please make sure kubeconfig points to the right cluster! (y/N): " -n1 confirmation

if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
    echo "Operation canceled."
    exit 1
fi

terraform destroy --auto-approve --var-file prod.tfvars