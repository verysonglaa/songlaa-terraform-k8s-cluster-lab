#!/bin/bash
OUTPUT_LIST=".links.csv"
lab_environment="training.cluster.songlaa.com"
TOKEN=$(kubectl -n kubernetes-dashboard get secrets read-only-user-token -o jsonpath="{.data.token}" | base64 --decode)

# Start the user at user4:
line=4
echo "" > "$OUTPUT_LIST" 
for i in {0..26}; do

    export user="user"$((i+1))
    pwd=$(kubectl -n $user get secrets acend-userconfig -o jsonpath="{.data.password}" | base64 --decode)
    echo "https://$user:$pwd@$user.$lab_environment,$user,$pwd,https://container-training.songlaa.com,https://kubernetes-training.songlaa.com?n=$user" >> $OUTPUT_LIST

done

