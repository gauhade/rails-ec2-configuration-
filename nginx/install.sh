apt-get update
apt-get upgrade -y
apt-get install software-properties-common python-software-properties -y
add-apt-repository ppa:nginx/stable -y
apt-get install nginx -y
echo "Changing config file..."
sed -i "s@# gzip@gzip@" /etc/nginx/nginx.conf
start_sh="/etc/init.d/nginx start"
if grep -q "${start_sh}" "/etc/rc.local"; then echo "already appened"; else sed -i -e '$i '"$start_sh"'\n' /etc/rc.local; fi;
  echo "Done!\n"
echo "Reloading nginx..."
service nginx reload
