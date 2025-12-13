#!/bin/bash
OUTPUT_LIST=".links.csv"
OUTPUT_LIST_HUMANREADABLE=".links_human_readable.csv"
lab_environment="training.cluster.songlaa.com"
TOKEN=$(kubectl -n kubernetes-dashboard get secrets read-only-user-token -o jsonpath="{.data.token}" | base64 --decode)

# Start the user at user4:
line=2
echo "" > "$OUTPUT_LIST" 
echo -e "User \t Link \t Username \t Password \t Container Training \t Kubernetes Training" > "$OUTPUT_LIST_HUMANREADABLE"
for i in {0..26}; do

    export user="user"$((i+1))
    pwd=$(kubectl -n $user get secrets acend-userconfig -o jsonpath="{.data.password}" | base64 --decode)
    echo "https://$user:$pwd@$user.$lab_environment,$user,$pwd,https://container-training.songlaa.com,https://kubernetes-training.songlaa.com?n=$user" >> $OUTPUT_LIST
    echo -e "$user \t https://$user:$pwd@$user.$lab_environment \t $user \t $pwd \t https://container-training.songlaa.com \t https://kubernetes-training.songlaa.com?n=$user" >> $OUTPUT_LIST_HUMANREADABLE

done

