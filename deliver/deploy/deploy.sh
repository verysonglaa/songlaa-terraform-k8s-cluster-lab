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


echo "---------------------------------" > .ssh-connection.txt
echo "---------------------------------" > .email-templates.txt

OUTPUT_FILE=".email-templates.txt"
EMAIL_LIST="emails.txt"
training_course="https://course.songlaa.com"
lab_environment="training.cluster.songlaa.com"
slides="https://slides.songlaa.com"
TOKEN=$(kubectl -n kubernetes-dashboard get secrets read-only-user-token -o jsonpath="{.data.token}" | base64 --decode)


# Start the user at user4:
line=4

# Read the file line by line
while IFS= read -r email; do
  # Extract prename and name from the email
  prename=$(echo "$email" | cut -d '@' -f 1 | cut -d '.' -f 1)
  name=$(echo "$email" | cut -d '@' -f 1 | cut -d '.' -f 2)

  # Export or assign variables for each line
  eval "prename$line=\"$prename\""
  eval "name$line=\"$name\""
  eval "email$line=\"$email\""
  eval "user$line=\"$prename $name <$email>\""
  pwd=$(kubectl -n user1 get secrets acend-userconfig -o jsonpath="{.data.password}" | base64 --decode)

  cat >> "$OUTPUT_FILE" <<EOF
Subject:
E-mail: $email

Dear ${prename^} ${name^},

Welcome to your training course. You can access the course materials at:
$training_course?n=user$line

You can access your personalized training environment at: 
https://user$line:$pwd@$lab_environment
user: user$line
password: $pwd

You can find the slides of today's session here:
$slides

Your token is:
$TOKEN

Best regards,
EOF

  echo "" >> "$OUTPUT_FILE" # optional: add an empty line between messages

  # Increment line counter
  ((line++))
done < "$EMAIL_LIST"


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