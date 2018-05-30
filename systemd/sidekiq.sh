echo "rails app name?"
read APP_NAME

bin_file="/usr/bin/sidekiq-${APP_NAME}"
curl -o $bin_file -sSL http://saturn.5fpro.com/systemd/sidekiq/bin.sh
chmod +x $bin_file

systemd_service="/etc/systemd/system/sidekiq-${APP_NAME}.service"
test -f $systemd_service && (rm $systemd_service) && (systemctl daemon-reload)
curl -o $systemd_service -sSL http://saturn.5fpro.com/systemd/sidekiq/systemd.service
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

echo "sidekiq pid dir path? (${APP_ROOT}/shared/tmp/pids)"
read SIDEKIQ_PID_PATH
if [ "$SIDEKIQ_PID_PATH" == "" ]; then SIDEKIQ_PID_PATH="${APP_ROOT}/shared/tmp/pids"; fi;
sed -i "s@{{SIDEKIQ_PID_PATH}}@${SIDEKIQ_PID_PATH}@" $bin_file

echo "sidekiq pid file path? (${SIDEKIQ_PID_PATH}/sidekiq-0.pid)"
read SIDEKIQ_PID
if [ "$SIDEKIQ_PID" == "" ]; then SIDEKIQ_PID="${SIDEKIQ_PID_PATH}/sidekiq-0.pid"; fi;
sed -i "s@{{SIDEKIQ_PID}}@${SIDEKIQ_PID}@" $bin_file
sed -i "s@{{SIDEKIQ_PID}}@${SIDEKIQ_PID}@" $systemd_service

echo "sidekiq config file path? (${APP_ROOT}/current/config/sidekiq.yml)"
read SIDEKIQ_CONFIG_FILE
if [ "$SIDEKIQ_CONFIG_FILE" == "" ]; then SIDEKIQ_CONFIG_FILE="${APP_ROOT}/current/config/sidekiq.yml"; fi;
sed -i "s@{{SIDEKIQ_CONFIG_FILE}}@${SIDEKIQ_CONFIG_FILE}@" $bin_file

echo "sidekiq log file path? (${APP_ROOT}/current/log/sidekiq.log)"
read SIDEKIQ_LOG_FILE
if [ "$SIDEKIQ_LOG_FILE" == "" ]; then SIDEKIQ_LOG_FILE="${APP_ROOT}/current/log/sidekiq.log"; fi;
sed -i "s@{{SIDEKIQ_LOG_FILE}}@${SIDEKIQ_LOG_FILE}@" $bin_file

systemd_start_cmd="systemctl start sidekiq-${APP_NAME}"
echo "append to /etc/rc.local"
if grep -q "start sidekiq-${APP_NAME}" "/etc/rc.local"; then echo "already appened"; else sed -i -e '$i '"$systemd_start_cmd"'\n' /etc/rc.local; fi;
echo "Enabling systemd service..."
systemctl daemon-reload
systemctl start sidekiq-$APP_NAME
