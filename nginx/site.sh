echo "App name?"
read APP_NAME

conf_file="/etc/nginx/sites-available/${APP_NAME}"
dist_file="/etc/nginx/sites-enabled/${APP_NAME}"
curl -o $conf_file -sSL http://saturn.5fpro.com/nginx/site.conf
force_redirect_conf="/tmp/force_redirect_conf"
curl -o $force_redirect_conf -sSL http://saturn.5fpro.com/nginx/force-redirect.conf

sed -i "s@{{APP_NAME}}@${APP_NAME}@" $conf_file

DEFAULT_APP_ROOT="/home/apps/${APP_NAME}"
echo "App roor path WITHOUT current?(${DEFAULT_APP_ROOT})"
read APP_ROOT
if [ "$APP_ROOT" == "" ]; then APP_ROOT="${DEFAULT_APP_ROOT}"; fi;
sed -i "s@{{APP_ROOT}}@${APP_ROOT}@" $conf_file

echo "Main domain name?"
read SERVER_NAME
sed -i "s@{{SERVER_NAME}}@${SERVER_NAME}@" $conf_file

echo "Set as default server? (y/N)"
read DEFAULT_SERVER
if [[ ($DEFAULT_SERVER == "y") && ($DEFAULT_SERVER != "Y") ]]; then
  DEFAULT_SERVER=" default_server"
  sed -i "s@{{DEFAULT_SERVER}}@${DEFAULT_SERVER}@" $conf_file
else
  sed -i "s@{{DEFAULT_SERVER}}@@" $conf_file
fi;

DEFAULT_UNICORN_SOCK="/tmp/unicorn.${APP_NAME}.sock"
echo "Unicorn sock file path? (${DEFAULT_UNICORN_SOCK})"
read UNICORN_SOCK
if [ "$UNICORN_SOCK" == "" ]; then UNICORN_SOCK="${DEFAULT_UNICORN_SOCK}"; fi;
sed -i "s@{{UNICORN_SOCK}}@${UNICORN_SOCK}@" $conf_file

DEFAULT_ASSETS_FOLDERS="assets|uploads"
echo "Assets folders under ${APP_ROOT}/current/public? (${DEFAULT_ASSETS_FOLDERS})"
read ASSETS_FOLDERS
if [ "$ASSETS_FOLDERS" == "" ]; then ASSETS_FOLDERS="${DEFAULT_ASSETS_FOLDERS}"; fi;
sed -i "s@{{ASSETS_FOLDERS}}@${ASSETS_FOLDERS}@" $conf_file

DEFAULT_ASSETS_FILE_EXTS="htm|fon|fnt"
echo "Assets files extensions under ${APP_ROOT}/current/public? (${DEFAULT_ASSETS_FILE_EXTS})"
read ASSETS_FILE_EXTS
if [ "$ASSETS_FILE_EXTS" == "" ]; then ASSETS_FILE_EXTS="${DEFAULT_ASSETS_FILE_EXTS}"; fi;
sed -i "s@{{ASSETS_FILE_EXTS}}@${ASSETS_FILE_EXTS}@" $conf_file

echo "Enable SSL?(y/N)"
read SSL
if [[ ("$SSL" == "y") || ("$SSL" == "Y") ]]; then
  PROTOCOL="https"
  sed -i "s@# listen 443@listen 443@" $conf_file
  sed -i "s@# ssl@ssl@" $conf_file
else
  PROTOCOL="http"
fi;
sed -i "s@{{PROTOCOL}}@${PROTOCOL}@" $conf_file

echo "Force redirect domains with http(80), space for separate? (ENTER to skip)"
read OTHER_DOMAINS
if [[ "$OTHER_DOMAINS" == "" ]]; then
  echo 'skip force redirect...'
  # sed "s@{{FORCE_REDIRECT}}@@" $conf_file
else
  sed -i "s@{{PROTOCOL}}@${PROTOCOL}@" $force_redirect_conf
  sed -i "s@{{DOMAINS}}@${OTHER_DOMAINS}@" $force_redirect_conf
  sed -i "s@{{SERVER_NAME}}@${SERVER_NAME}@" $force_redirect_conf
  if [[ $PROTOCOL == 'https' ]]; then
    sed -i "s@listen 80@# listen 80@" $conf_file
  fi;
  str=`cat ${force_redirect_conf}`
  echo "$str" >> $conf_file
fi;

if [ -f "$dist_file" ]; then
  echo ""
else
  ln -s $conf_file $dist_file
fi;
service nginx reload
rm $force_redirect_conf

# log rotate
log_rotate_dist="/etc/logrotate.d/rails-${APP_NAME}"
curl -o $log_rotate_dist -sSL http://saturn.5fpro.com/nginx/site-log-rotate.conf
sed -i "s@{{APP_ROOT}}@${APP_ROOT}@" $log_rotate_dist
