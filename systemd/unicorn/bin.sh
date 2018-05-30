#!/bin/sh
set -e

# Include Bundler path
PATH=$PATH:/usr/local/bin

### Unicorn Variables ###

TIMEOUT=60

# 你的 rails app dir
APP_ROOT={{APP_ROOT}}/current

# rails env
RAILS_ENV={{RAILS_ENV}}

# deploy user
DEPLOY_USER={{DEPLOY_USER}}

# deploy group
DEPLOY_GROUP={{DEPLOY_GROUP}}

# unicorn pid dir
UNICORN_PID_PATH={{UNICORN_PID_PATH}}

# unicorn pid file path
UNICORN_PID={{UNICORN_PID}}

# unicorn config, 不同環境用不同檔名
UNICORN_CONFIG_FILE={{UNICORN_CONFIG_FILE}}

USER_HOME="/home/${DEPLOY_USER}"
RUBY_VERSION=`cat ${APP_ROOT}/.ruby-version`
BUNDLE_PREFIX="RBENV_ROOT=$USER_HOME/.rbenv RBENV_VERSION=$RUBY_VERSION $USER_HOME/.rbenv/bin/rbenv exec"

me=$(whoami)

# full command
START_CMD="cd ${APP_ROOT} && ( export RAILS_ENV=\"${RAILS_ENV}\" ; ${BUNDLE_PREFIX} bundle exec unicorn -c ${UNICORN_CONFIG_FILE} -E deployment -D )"
pid_number=`(test -f $UNICORN_PID && cat $UNICORN_PID) || (ps -ef | grep "master -c $UNICORN_CONFIG_FILE" | grep -v grep | awk '{print $2}')`
STOP_CMD="kill -s QUIT $pid_number"
RESTART_CMD="kill -s USR2 $pid_number"

if [ $me = "root" ]; then
  START_CMD="sudo -H -u $DEPLOY_USER bash -c \"$START_CMD\""
  STOP_CMD="sudo -H -u $DEPLOY_USER bash -c \"$STOP_CMD\""
  RESTART_CMD="sudo -H -u $DEPLOY_USER bash -c \"$RESTART_CMD\""
fi;

action="$1"
set -u

# 檢查PID, 並且砍掉該服務
sig () {
  test -n $pid_number && kill -$1 $pid_number
}

# 檢查路徑, 如果不存在就自行開路徑
create_if_not_exists () {
  test -d $UNICORN_PID_PATH || (mkdir -p $UNICORN_PID_PATH && chown $DEPLOY_USER.$DEPLOY_GROUP $UNICORN_PID_PATH)
}


case $action in
start)
  create_if_not_exists
  # sig 0 && echo >&2 "Already running" && exit 0
  bash -c "$START_CMD"
;;
stop)
  bash -c "$STOP_CMD"
;;
restart)
  bash -c "$RESTART_CMD"
;;
*)
  echo >&2 "Usage: $0 <start|stop|restart>"
  exit 1
;;
esac
