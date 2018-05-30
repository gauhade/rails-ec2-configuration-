echo "Domain name?"
read DOMAIN_NAME
filename=(${DOMAIN_NAME// \-d/ })
filename=`echo $filename|sed 's/\./\-/g'`
cron_file="/etc/cron.weekly/ssl-renewal-${filename}"
renew_cmd="/etc/dehydrated/dehydrated -c -d ${DOMAIN_NAME} && /etc/init.d/nginx restart"
touch $cron_file
echo "#!/bin/sh" >> $cron_file
echo $renew_cmd >> $cron_file
chmod +x $cron_file

echo "Test?(y/N)"
read run
if [[ $run == 'y' ]]; then
  bash -c "$renew_cmd"
fi
