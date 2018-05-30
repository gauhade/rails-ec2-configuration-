file="/etc/init.d/nginx"
if [ -f "$file" ]
then
  echo 'Detected nginx installed'
else
  read -p "nginx not install, press ENTER to install or ^C to cancel" ans
  curl -o /tmp/install-nginx.sh http://saturn.5fpro.com/nginx/install.sh
  chmod +x /tmp/install-nginx.sh
  /tmp/install-nginx.sh
  rm /tmp/install-nginx.sh
fi

read -p "setup site for nginx? (Y/n)" ans
if [[ ($ans != "n") && ($ans != "N") ]]; then
  curl -o /tmp/site.sh http://saturn.5fpro.com/nginx/site.sh
  chmod +x /tmp/site.sh
  /tmp/site.sh
  rm /tmp/site.sh
fi;
