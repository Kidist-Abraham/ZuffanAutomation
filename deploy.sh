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

if [[ -z "$file" ]]; then
    echo "Must provide the file." 1>&2
    exit 1
fi

if [[ -z "$temp" ]]; then
    echo "Must provide the temp option." 1>&2
    exit 1
fi

if [[ "$temp" == "true" ]]
then
bash $pwd/create-domain.sh --domain $domain 
fi

IMAGE=ubuntu/apache2:2.4-21.04_beta


docker run -d --name $file  -v /home/ubuntu/data/web/$file/:/var/www/html -e TZ=UTC -p 80 $IMAGE

port=$(docker inspect -f '{{ (index (index .NetworkSettings.Ports "80/tcp") 0).HostPort }}' $file)

bash $pwd/set_up_proxy.sh --domain $domain --port $port
