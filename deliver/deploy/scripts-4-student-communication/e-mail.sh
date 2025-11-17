#!/bin/bash

# Path to your file with emails (one per line in format prename.name@domain)
EMAIL_LIST="emails.txt"

# Initialize line counter
line=1

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

  # Optionally print what was parsed
  echo "User$line: $prename $name <$email>"

  # Increment line counter
  ((line++))
done < "$EMAIL_LIST"

