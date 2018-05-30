nginx_conf="/etc/monit/conf-available/nginx"
linked_file="/etc/monit/conf-enabled/nginx"
curl -o $nginx_conf -sSL http://saturn.5fpro.com/monit/nginx/monit.conf

echo "nginx pid file? (/var/run/nginx.pid)"
read NGINX_PID
if [ "$NGINX_PID" == "" ]; then NGINX_PID="/var/run/nginx.pid"; fi;
sed -i "s@{{NGINX_PID}}@${NGINX_PID}@" $nginx_conf

echo "start nginx? (/bin/bash -c 'systemctl start nginx')"
read NGINX_START
if [ "$NGINX_START" == "" ]; then NGINX_START="/bin/bash -c 'systemctl start nginx'"; fi;
sed -i "s@{{NGINX_START}}@${NGINX_START}@" $nginx_conf

echo "stop nginx? (/bin/bash -c 'systemctl stop nginx')"
read NGINX_STOP
if [ "$NGINX_STOP" == "" ]; then NGINX_STOP="/bin/bash -c 'systemctl stop nginx'"; fi;
sed -i "s@{{NGINX_STOP}}@${NGINX_STOP}@" $nginx_conf

echo "Writing conf file to ${nginx_conf}"
echo "restarting monit..."
ln -s $nginx_conf $linked_file
/etc/init.d/monit reload
