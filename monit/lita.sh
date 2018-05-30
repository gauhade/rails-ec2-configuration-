echo "lita app name?"
read APP_NAME

init_file="/etc/init.d/lita-${APP_NAME}"
curl -o $init_file -sSL http://saturn.5fpro.com/monit/lita/bin.sh
chmod +x $init_file

monit_file="/etc/monit/conf-available/lita-${APP_NAME}"
linked_file="/etc/monit/conf-enabled/lita-${APP_NAME}"
curl -o $monit_file -sSL http://saturn.5fpro.com/monit/lita/monit.conf
sed -i "s@{{INIT_FILE}}@${init_file}@" $monit_file
sed -i "s@{{APP_NAME}}@${APP_NAME}-lita@" $monit_file

echo "Your app full path?"
read APP_ROOT
sed -i "s@{{APP_ROOT}}@${APP_ROOT}@" $init_file

echo "deploy user? (apps)"
read DEPLOY_USER
if [ "$DEPLOY_USER" == "" ]; then DEPLOY_USER="apps"; fi;
sed -i "s@{{DEPLOY_USER}}@${DEPLOY_USER}@" $init_file

echo "deploy group? (apps)"
read DEPLOY_GROUP
if [ "$DEPLOY_GROUP" == "" ]; then DEPLOY_GROUP="apps"; fi;
sed -i "s@{{DEPLOY_GROUP}}@${DEPLOY_GROUP}@" $init_file

echo "pid dir path? (${APP_ROOT}/shared/tmp/pids)"
read PID_PATH
if [ "$PID_PATH" == "" ]; then PID_PATH="${APP_ROOT}/shared/tmp/pids"; fi;
sed -i "s@{{PID_PATH}}@${PID_PATH}@" $init_file

echo "pid file path? (${PID_PATH}/lita.pid)"
read PID_FILE
if [ "$PID_FILE" == "" ]; then PID_FILE="${PID_PATH}/lita.pid"; fi;
sed -i "s@{{PID_FILE}}@${PID_FILE}@" $init_file
sed -i "s@{{PID_FILE}}@${PID_FILE}@" $monit_file

echo "Your stage? (staging)"
read STAGE
if [ "$STAGE" == "" ]; then STAGE="staging"; fi;
sed -i "s@{{STAGE}}@${STAGE}@" $init_file

echo "log file path? (${APP_ROOT}/shared/log/${STAGE}.log)"
read LOG_FILE
if [ "$LOG_FILE" == "" ]; then LOG_FILE="${APP_ROOT}/shared/log/${STAGE}.log"; fi;
sed -i "s@{{LOG_FILE}}@${LOG_FILE}@" $init_file

echo "append '${init_file} start' to /etc/rc.local"
if grep -q "${init_file} start" "/etc/rc.local"; then echo "already appened"; else sed -i -e '$i '"$init_file"' start\n' /etc/rc.local; fi;
echo "restarting monit..."
ln -s $monit_file $linked_file
/etc/init.d/monit reload
