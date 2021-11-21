#!/bin/bash

set -e

while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
   fi

  shift
done

if [[ -z "$domain" ]]; then
    echo "Must provide the domain." 1>&2
    exit 1
fi

# Update a record to point to the instance. 

IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

# A config that updates $domain record to point to the ip address on the instance which is $${IP}
route53_config="$(cat << EOF
{
    "Comment": "CREATE/DELETE/UPSERT a record ",
    "Changes": [{
    "Action": "UPSERT",
                "ResourceRecordSet": {
                            "Name": "$domain",
                            "Type": "A",
                            "TTL": 300,
                         "ResourceRecords": [{ "Value": "$IP"}]
}}]
}
EOF
)"


echo $route53_config > /tmp/config.json

# The follwing will update rout53 record using the above config. It uses the AWS credentials to perform this task and the HOSTED_ZONE_ID of the record.
echo "updating rout53 record"
aws route53 change-resource-record-sets --hosted-zone-id Z08483702UGGU411VNZUB --change-batch file:///tmp/config.json
sleep 5