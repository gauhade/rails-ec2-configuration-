#!/bin/sh
set -e

# Include Bundler path
PATH=$PATH:/usr/local/bin

# 你的 rails app dir
APP_ROOT={{APP_ROOT}}
APP_ROOT="${APP_ROOT}/current"

# deploy user
DEPLOY_USER={{DEPLOY_USER}}

# deploy group
DEPLOY_GROUP={{DEPLOY_GROUP}}

# sidekiq pid dir
PID_PATH={{PID_PATH}}

# sidekiq pid file path
PID_FILE={{PID_FILE}}

# sidekiq log file path
LOG_FILE={{LOG_FILE}}

USER_HOME="/home/${DEPLOY_USER}"
RUBY_VERSION=`cat ${APP_ROOT}/.ruby-version`
BUNDLE_PREFIX="RBENV_ROOT=$USER_HOME/.rbenv RBENV_VERSION=$RUBY_VERSION $USER_HOME/.rbenv/bin/rbenv exec"

# full command
CMD="cd ${APP_ROOT} && (${BUNDLE_PREFIX} bundle exec lita >> ${LOG_FILE} 2>&1 & echo \$! > ${PID_FILE})"

action="$1"
set -u

sig () {
  (test -s $PID_FILE) && (ps -p `cat $PID_FILE` > /dev/null 2>&1) && (kill -$1 `cat $PID_FILE`)
}

create_PID_PATH () {
  test -d $PID_PATH || (mkdir -p $PID_PATH && chown $DEPLOY_USER.$DEPLOY_GROUP $PID_PATH)
}

case $action in
start)
  create_PID_PATH
  sig 0 && echo >&2 "Already running" && exit 0
  sudo -H -u $DEPLOY_USER bash -c "$CMD" # 使用 $DEPLOY_USER 執行指令
;;
stop)
  sig QUIT && exit 0
  echo >&2 "Not running"
;;
*)
  echo >&2 "Usage: $0 <start|stop>"
  exit 1
;;
esac
