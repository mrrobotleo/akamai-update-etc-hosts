#!/bin/sh

echo "---------------------------------------"
echo "Update /etc/hosts file for Akamai tests"
echo "---------------------------------------"

if [ -z "$1" ]
  then
    echo "No argument supplied. Please insert environment on cli."
    echo "prd CLI: ./aka-env.sh prd"
    echo "stg CLI: ./aka-env.sh stg"
    exit 1
fi

# update akamai/domain entry
AKAPRDHOST="xxx.net.edgekey.net."
AKASTGHOST="xxx.net.edgekey-staging.net."
DOMAIN="www.xxx.com"

if [ $1 = "prd" ]; then
   akaip=$(ping -c1 $AKAPRDHOST | sed -nE 's/^PING[^(]+\(([^)]+)\).*/\1/p')
elif [ $1 = "stg" ]; then
   akaip=$(ping -c1 $AKASTGHOST | sed -nE 's/^PING[^(]+\(([^)]+)\).*/\1/p')
else
   echo "please select the akamai environment (prd or stg)"
   exit 1
fi

# https://stackoverflow.com/questions/19339248/append-line-to-etc-hosts-file-with-shell-script
# find existing domain in the host file
match_host="$(grep -n $DOMAIN /etc/hosts | cut -f1 -d:)"

host_entry="${akaip} ${DOMAIN}"

if [ ! -z "$match_host" ]
then
   echo "Updating existing hosts entry."
   # iterate over the line numbers on which matches were found
   while read -r line_number; do
      # replace the text of each line with the desired host entry
      sudo sed -i '' "${line_number}s/.*/${host_entry} /" /etc/hosts
   done <<< "$match_host"

else
   echo "adding new hosts entry"
   echo "$host_entry" | sudo tee -a /etc/hosts > /dev/null
fi
