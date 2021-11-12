# Setup a cron job for cert renewal. The cron job is schedules to run every 75 days starting from the day this script is running.
today=$(date +'%Y-%m-%d')
domain=$1
sudo domain=$domain today=$today -u ubuntu crontab<<EOF
$(crontab -l)
0 3 * * * bash -c '(( \$(date +\%s) / 86400 \% 75 == (( \$(date +\%s -d "${today}") / 86400 \% 75 )) )) && sudo certbot renew --cert-name ${domain} && sudo systemctl restart nginx'
EOF
