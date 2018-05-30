echo "rails dir or app name?"
read APP_NAME

bin_file="/usr/bin/unicorn-${APP_NAME}"
curl -o $bin_file -sSL http://saturn.5fpro.com/systemd/unicorn/bin.sh
chmod +x $bin_file

systemd_service="/etc/systemd/system/unicorn-${APP_NAME}.service"
test -f $systemd_service && (rm $systemd_service) && (systemctl daemon-reload)
curl -o $systemd_service -sSL http://saturn.5fpro.com/systemd/unicorn/systemd.service
chmod 644 $systemd_service
sed -i "s@{{APP_NAME}}@${APP_NAME}@" $systemd_service

start_cmd="$bin_file start"
stop_cmd="$bin_file stop"
restart_cmd="$bin_file restart"
sed -i "s@{{START_CMD}}@${start_cmd}@" $systemd_service
sed -i "s@{{STOP_CMD}}@${stop_cmd}@" $systemd_service
sed -i "s@{{RESTART_CMD}}@${restart_cmd}@" $systemd_service

echo "Your app full path WITHOUT current dir?"
read APP_ROOT
sed -i "s@{{APP_ROOT}}@${APP_ROOT}@" $bin_file

echo "rails env? (staging)"
read RAILS_ENV
if [ "$RAILS_ENV" == "" ]; then RAILS_ENV="staging"; fi;
sed -i "s@{{RAILS_ENV}}@${RAILS_ENV}@" $bin_file

echo "deploy user? (apps)"
read DEPLOY_USER
if [ "$DEPLOY_USER" == "" ]; then DEPLOY_USER="apps"; fi;
sed -i "s@{{DEPLOY_USER}}@${DEPLOY_USER}@" $bin_file

echo "deploy group? (apps)"
read DEPLOY_GROUP
if [ "$DEPLOY_GROUP" == "" ]; then DEPLOY_GROUP="apps"; fi;
sed -i "s@{{DEPLOY_GROUP}}@${DEPLOY_GROUP}@" $bin_file

echo "unicorn pid dir path? (${APP_ROOT}/current/tmp/pids)"
read UNICORN_PID_PATH
if [ "$UNICORN_PID_PATH" == "" ]; then UNICORN_PID_PATH="${APP_ROOT}/current/tmp/pids"; fi;
sed -i "s@{{UNICORN_PID_PATH}}@${UNICORN_PID_PATH}@" $bin_file

echo "unicorn pid file path? (${UNICORN_PID_PATH}/unicorn.pid)"
read UNICORN_PID
if [ "$UNICORN_PID" == "" ]; then UNICORN_PID="${UNICORN_PID_PATH}/unicorn.pid"; fi;
sed -i "s@{{UNICORN_PID}}@${UNICORN_PID}@" $bin_file
sed -i "s@{{PID_FILE_PATH}}@${UNICORN_PID}@" $systemd_service

echo "unicorn config file path? (${APP_ROOT}/current/config/unicorn/${RAILS_ENV}.rb)"
read UNICORN_CONFIG_FILE
if [ "$UNICORN_CONFIG_FILE" == "" ]; then UNICORN_CONFIG_FILE="${APP_ROOT}/current/config/unicorn/${RAILS_ENV}.rb"; fi;
sed -i "s@{{UNICORN_CONFIG_FILE}}@${UNICORN_CONFIG_FILE}@" $bin_file

systemd_start_cmd="systemctl start unicorn-${APP_NAME}"
echo "append to /etc/rc.local"
if grep -q "start unicorn-${APP_NAME}" "/etc/rc.local"; then echo "already appened"; else sed -i -e '$i '"$systemd_start_cmd"'\n' /etc/rc.local; fi;
echo "Enabling systemd service..."
systemctl daemon-reload
systemctl start unicorn-$APP_NAME
