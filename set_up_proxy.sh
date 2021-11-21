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

if [[ -z "$port" ]]; then
    echo "Must provide the port." 1>&2
    exit 1
fi


sudo certbot certonly --standalone -d $domain --email kidistabraham@gmail.com -n --agree-tos
sudo touch /etc/nginx/sites-available/$domain

sudo domain=$domain port=$port bash -c 'cat <<EOT > /etc/nginx/sites-available/${domain}
server {
  listen        443 ssl;
  server_name  ${domain};
    ssl_certificate /etc/letsencrypt/live/${domain}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${domain}/privkey.pem;
  location / {
    proxy_pass  http://localhost:${port};
  }
}
EOT'

sudo rm /etc/nginx/sites-enabled/${domain} 

sudo ln -s /etc/nginx/sites-available/${domain} /etc/nginx/sites-enabled/

sudo systemctl restart nginx

bash $PWD/cron-cert.sh  $domain 

echo "Finish setting up"
