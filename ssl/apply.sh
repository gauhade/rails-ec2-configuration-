echo "Make sure you have set nginx config and point target domain to this server on DNS setting, or you can run:"
echo ""
echo "  bash <(curl -s http://saturn.5fpro.com/nginx/site.sh)"
echo ""
echo "to setup."
echo "(press ENTER to continue)"
read GO

echo "Domain name? (For multiple domains example: 'example.com -d my.example.com'"
read DOMAIN_NAME

echo "Nginx config file under /etc/nginx/sites-available/ ?"
read NGINX_CONF

nginx_conf="/etc/nginx/sites-available/$NGINX_CONF"
ori_content=`cat $nginx_conf`

rm -rf ~/dehydrated/
cd ~; git clone https://github.com/lukas2511/dehydrated.git
cd dehydrated/
mkdir -p /etc/dehydrated/
cp ~/dehydrated/dehydrated /etc/dehydrated/
chmod a+x /etc/dehydrated/dehydrated
mkdir -p /var/www/dehydrated/
if grep -q "acme\-challenge" $nginx_conf; then
  echo "configed..."
else
  line_for_ssl="\
  location /.well-known/acme-challenge/ { alias /var/www/dehydrated/; }
  "
  sed -i "/listen 80/a ${line_for_ssl}" $nginx_conf
  echo 'nginx reloading...'
  service nginx restart
fi

/etc/dehydrated/dehydrated --register --accept-terms
/etc/dehydrated/dehydrated -c -d $DOMAIN_NAME

# Setting SSL

tmp_file="/tmp/line_for_443"
echo "\
    listen 443 ssl http2;
    ssl on;
    ssl_certificate /etc/dehydrated/certs/${DOMAIN_NAME}/fullchain.pem;
    ssl_certificate_key /etc/dehydrated/certs/${DOMAIN_NAME}/privkey.pem;

    ssl_dhparam /etc/nginx/cert/dhparam.pem;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DH+3DES:!ADH:!AECDH:!MD5;
    ssl_session_cache shared:SSL:20m;
    ssl_session_timeout 180m;

    add_header Strict-Transport-Security \"max-age=31536000; includeSubDomains\";

" >> $tmp_file
echo "SSL settings to conf?[Y/n]"
read ssl_set

dhparam_file="/etc/nginx/cert/dhparam.pem"
if [ -f "$dhparam_file" ]; then
  echo "$dhparam_file already exists"
else
  mkdir -p /etc/nginx/cert/
  openssl dhparam 2048 -out /etc/nginx/cert/dhparam.pem
fi;

if grep -q "listen 443" $nginx_conf; then
  sed -i "s@# listen 443@listen 443@" $nginx_conf
  sed -i "s@# ssl@ssl@" $nginx_conf
else
  if [[ $ssl_set == 'n' || $ssl_set == 'N' ]]; then
    echo "------------------------------------"
    echo `cat $tmp_file`
    echo "------------------------------------"
  else
    sed -i "/listen 80/r ${tmp_file}" $nginx_conf
  fi
fi
rm $tmp_file

# Force 80 to 443

echo "Force ssl? (Y/n)"
read force_ssl
if [[ $force_ssl == 'n' || $force_ssl == 'N' ]]; then
  echo ""
else
  sed -i '/acme\-challenge/d' $nginx_conf
  sed -i '/listen 80/{//d;}' $nginx_conf
  str="\
  server {
    listen 80;
    server_name ${DOMAIN_NAME};
    location /.well-known/acme-challenge/ { alias /var/www/dehydrated/; }
    location / {
      rewrite ^ https://${DOMAIN_NAME}\$request_uri? permanent;
      # rewrite ^ https://\$http_host\$request_uri? permanent;
    }
  }
  "
  if [[ $ssl_set == 'n' || $ssl_set == 'N' ]]; then
    echo "------------------------------------"
    echo $str
    echo "------------------------------------"
  else
    echo $str >> $nginx_conf
  fi
fi

echo "auto renew certs?[Y/n]"
read autorenew
if [[ $autorenew == 'n' ]]; then
  echo "Done!"
  service nginx restart
else
  bash <(curl -s http://saturn.5fpro.com/ssl/renew.sh)
fi
