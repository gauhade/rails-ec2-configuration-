#!/bin/sh
set -e

# Include Bundler path
PATH=$PATH:/usr/local/bin

# rails app dir
APP_ROOT={{APP_ROOT}}/current

# rails env
RAILS_ENV={{RAILS_ENV}}

# deploy user
DEPLOY_USER={{DEPLOY_USER}}

# deploy group
DEPLOY_GROUP={{DEPLOY_GROUP}}

# sidekiq pid dir
SIDEKIQ_PID_PATH={{SIDEKIQ_PID_PATH}}

# sidekiq pid file path
SIDEKIQ_PID={{SIDEKIQ_PID}}

# sidekiq config yml file path
SIDEKIQ_CONFIG_FILE={{SIDEKIQ_CONFIG_FILE}}

# sidekiq log file path
SIDEKIQ_LOG_FILE={{SIDEKIQ_LOG_FILE}}

USER_HOME="/home/${DEPLOY_USER}"
RUBY_VERSION=`cat ${APP_ROOT}/.ruby-version`
BUNDLE_PREFIX="RBENV_ROOT=$USER_HOME/.rbenv RBENV_VERSION=$RUBY_VERSION $USER_HOME/.rbenv/bin/rbenv exec"
CMD_PREFIX="cd $APP_ROOT && $BUNDLE_PREFIX bundle exec"

me=$(whoami)

START_CMD="${CMD_PREFIX} sidekiq --index 0 --pidfile $SIDEKIQ_PID --environment $RAILS_ENV --logfile $SIDEKIQ_LOG_FILE --config $SIDEKIQ_CONFIG_FILE --daemon"
STOP_CMD="${CMD_PREFIX} sidekiqctl stop ${SIDEKIQ_PID} 10"
RESTART_CMD="$STOP_CMD; $START_CMD"

if [ $me = "root" ]; then
  START_CMD="sudo -H -u $DEPLOY_USER bash -c \"$START_CMD\""
  STOP_CMD="sudo -H -u $DEPLOY_USER bash -c \"$STOP_CMD\""
  RESTART_CMD="sudo -H -u $DEPLOY_USER bash -c \"$RESTART_CMD\""
fi;

action="$1"
set -u

# 檢查PID, 並且砍掉該服務
sig () {
  test -s "$SIDEKIQ_PID" && kill -$1 `cat $SIDEKIQ_PID`
}

# 檢查路徑, 如果不存在就自行開路徑
create_SIDEKIQ_PID_PATH () {
  test -d $SIDEKIQ_PID_PATH || (mkdir -p $SIDEKIQ_PID_PATH && chown $DEPLOY_USER.$DEPLOY_GROUP $SIDEKIQ_PID_PATH)
}

case $action in
start)
  create_SIDEKIQ_PID_PATH
  sig 0 && echo >&2 "Already running" && exit 0
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
