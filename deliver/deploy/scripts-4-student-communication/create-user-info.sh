#!/bin/bash

# This script reads a list of email addresses from a file and generates personalized email templates

echo "---------------------------------" > .ssh-connection.txt
echo "---------------------------------" > .email-templates.txt

# get absolute path of the script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

OUTPUT_FILE="./current_instance/.email-templates.txt"
OUTPUT_LIST="./current_instance/.links.csv"
OUTPUT_LIST_HUMANREADABLE="./current_instance/.links_human_readable.csv"

EMAIL_LIST="$SCRIPT_DIR/emails.txt"
students=$(wc -l < "$EMAIL_LIST")
training_course="https://course.songlaa.com"
lab_environment="training.cluster.songlaa.com"
slides="https://slides.songlaa.com"
TOKEN=$(kubectl -n kubernetes-dashboard get secrets read-only-user-token -o jsonpath="{.data.token}" | base64 --decode)

# add 3 teacher accounts to the student count
students=$((students + 3))
# Start the user at user4:
line=$students

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

You can find the slides here:
Container:  
Kubernetes:

Your token is:
$TOKEN

Best regards,
EOF

  echo "" >> "$OUTPUT_FILE" # optional: add an empty line between messages

  # Increment line counter
  ((line++))
done < "$EMAIL_LIST"


echo "generate ssh connection info for students:"

for ((i=0; i<=$students; i++)); do

    user="user"$((i+1))
    echo $i >> .ssh-connection.txt
    terraform output -json student-vm-ssh-keys | jq -r .[$i].private_key_openssh >> .ssh-connection.txt
    echo "ssh -i $user.pem $user@$(terraform output -json student-vm-ips | jq -r .[$i]) " >> .ssh-connection.txt
    echo >> .ssh-connection.txt
    echo "token:" >> ./current_instance/.ssh-connection.txt
    echo "$(kubectl -n kubernetes-dashboard get secrets read-only-user-token -o jsonpath="{.data.token}" | base64 --decode)" >> ./current_instance/.ssh-connection.txt
    echo "---------------------------------" >> ./current_instance/.ssh-connection.txt
done


echo "generate link list for students:"

echo "" > "$OUTPUT_LIST" 
echo -e "User \t Link \t Username \t Password \t Container Training \t Kubernetes Training" > "$OUTPUT_LIST_HUMANREADABLE"
for ((i=0; i<=$students; i++)); do

    export user="user"$((i+1))
    pwd=$(kubectl -n $user get secrets acend-userconfig -o jsonpath="{.data.password}" | base64 --decode)
    echo "https://$user:$pwd@$user.$lab_environment,$user,$pwd,https://container-training.songlaa.com?n=$user,https://kubernetes-training.songlaa.com?n=$user" >> $OUTPUT_LIST
    echo -e "$user \t https://$user:$pwd@$user.$lab_environment \t $user \t $pwd \t https://container-training.songlaa.com?n=$user \t https://kubernetes-training.songlaa.com?n=$user" >> $OUTPUT_LIST_HUMANREADABLE

done

cat >> "$OUTPUT_LIST" <<EOF
You can find the slides here:
Container:  https://drive.google.com/file/d/1A3PnnH1b-Gk_fc9MC2g9Jhs-hy5as4g-/view?usp=sharing
Kubernetes: https://drive.google.com/file/d/1tFljU9g94C3AfEIVleThRLFKNxYi3mb3/view?usp=sharing

Your token is:
$TOKEN
EOF

echo "Done. Generated ./current_instance/.email-templates.txt and ./current_instance/.ssh-connection.txt"
echo "Generated link list in ./current_instance/.links.csv"