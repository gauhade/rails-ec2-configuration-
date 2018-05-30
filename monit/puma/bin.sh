#!/bin/sh
set -e

# Include Bundler path
PATH=$PATH:/usr/local/bin

### Variables ###
TIMEOUT=60

# rails app dir without current
APP_ROOT={{APP_ROOT}}
CURRENT_PATH="$APP_ROOT/current"
SHARED_PATH="$APP_ROOT/shared"
PID_DIR_PATH="$SHARED_PATH/tmp/pids"
PID_FILE_PATH="$PID_DIR_PATH/puma.pid"
STATE_FILE_PATH="$PID_DIR_PATH/puma.state"
CONFIG_FILE_PATH="$SHARED_PATH/puma.rb"

# rails env
RAILS_ENV={{RAILS_ENV}}

# deploy user
DEPLOY_USER={{DEPLOY_USER}}

# deploy group
DEPLOY_GROUP={{DEPLOY_GROUP}}

USER_HOME="/home/${DEPLOY_USER}"
RUBY_VERSION=`cat ${CURRENT_PATH}/.ruby-version`
BUNDLE_PREFIX="RAILS_ENV=${RAILS_ENV} RBENV_ROOT=$USER_HOME/.rbenv RBENV_VERSION=$RUBY_VERSION $USER_HOME/.rbenv/bin/rbenv exec"
CMD_PREFIX="cd ${CURRENT_PATH} && ${BUNDLE_PREFIX} bundle exec"

action="$1"

me=$(whoami)

START_CMD="${CMD_PREFIX} puma -C ${CONFIG_FILE_PATH} --daemon"
RESTART_CMD="${CMD_PREFIX} pumactl -S ${STATE_FILE_PATH} restart"
STOP_CMD="${CMD_PREFIX} pumactl -S ${STATE_FILE_PATH} stop"

if [ $me = "root" ]; then
  START_CMD="sudo -H -u $DEPLOY_USER bash -c \"$START_CMD\""
  STOP_CMD="sudo -H -u $DEPLOY_USER bash -c \"$STOP_CMD\""
  RESTART_CMD="sudo -H -u $DEPLOY_USER bash -c \"$RESTART_CMD\""
fi;

set -u

sig () {
 test -s "$PID_FILE_PATH" && kill -$1 `cat $PID_FILE_PATH`
}

create_pid_path () {
 test -d $PID_DIR_PATH || (mkdir -p $PID_DIR_PATH && chown $DEPLOY_USER.$DEPLOY_GROUP $PID_DIR_PATH)
}



case $action in
start)
  create_pid_path
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
