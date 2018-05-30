echo "rails dir or app name?"
read APP_NAME

unicorn_file="/usr/sbin/unicorn-${APP_NAME}"
curl -o $unicorn_file -sSL http://saturn.5fpro.com/monit/unicorn/bin.sh
chmod +x $unicorn_file

unicorn_conf="/etc/monit/conf-available/unicorn-${APP_NAME}"
linked_file="/etc/monit/conf-enabled/unicorn-${APP_NAME}"
curl -o $unicorn_conf -sSL http://saturn.5fpro.com/monit/unicorn/monit.conf
sed -i "s@{{UNICORN_BIN_FILE}}@${unicorn_file}@" $unicorn_conf

sed -i "s@{{APP_NAME}}@${APP_NAME}-unicorn@" $unicorn_conf

echo "Your app full path with current dir?"
read APP_ROOT
sed -i "s@{{APP_ROOT}}@${APP_ROOT}@" $unicorn_file

echo "rails env? (staging)"
read RAILS_ENV
if [ "$RAILS_ENV" == "" ]; then RAILS_ENV="staging"; fi;
sed -i "s@{{RAILS_ENV}}@${RAILS_ENV}@" $unicorn_file

echo "deploy user? (apps)"
read DEPLOY_USER
if [ "$DEPLOY_USER" == "" ]; then DEPLOY_USER="apps"; fi;
sed -i "s@{{DEPLOY_USER}}@${DEPLOY_USER}@" $unicorn_file

echo "deploy group? (apps)"
read DEPLOY_GROUP
if [ "$DEPLOY_GROUP" == "" ]; then DEPLOY_GROUP="apps"; fi;
sed -i "s@{{DEPLOY_GROUP}}@${DEPLOY_GROUP}@" $unicorn_file

echo "unicorn pid dir path? (${APP_ROOT}/tmp/pids)"
read UNICORN_PID_PATH
if [ "$UNICORN_PID_PATH" == "" ]; then UNICORN_PID_PATH="${APP_ROOT}/tmp/pids"; fi;
sed -i "s@{{UNICORN_PID_PATH}}@${UNICORN_PID_PATH}@" $unicorn_file

echo "unicorn pid file path? (${UNICORN_PID_PATH}/unicorn.pid)"
read UNICORN_PID
if [ "$UNICORN_PID" == "" ]; then UNICORN_PID="${UNICORN_PID_PATH}/unicorn.pid"; fi;
sed -i "s@{{UNICORN_PID}}@${UNICORN_PID}@" $unicorn_file
sed -i "s@{{UNICORN_PID}}@${UNICORN_PID}@" $unicorn_conf

echo "unicorn config file path? (${APP_ROOT}/config/unicorn/${RAILS_ENV}.rb)"
read UNICORN_CONFIG_FILE
if [ "$UNICORN_CONFIG_FILE" == "" ]; then UNICORN_CONFIG_FILE="${APP_ROOT}/config/unicorn/${RAILS_ENV}.rb"; fi;
sed -i "s@{{UNICORN_CONFIG_FILE}}@${UNICORN_CONFIG_FILE}@" $unicorn_file

echo "generating bin file in ${unicorn_file}"
echo "generating conf file to ${unicorn_conf}"
echo "append '${unicorn_file} start' to /etc/rc.local"
if grep -q "${unicorn_file} start" "/etc/rc.local"; then echo "already appened"; else sed -i -e '$i '"$unicorn_file"' start\n' /etc/rc.local; fi;
echo "restarting monit..."
ln -s $unicorn_conf $linked_file
systemctl restart monit
