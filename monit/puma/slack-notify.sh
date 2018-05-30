message="[{{RAILS_ENV}}][$hostname] restarted puma process."
json="{\"text\":\"${message}\",\"username\": \"Monit\",\"channel\": \"{{slack_target}}\",\"icon_url\": \"http://i.imgur.com/qPR6qgF.png\"}"
curl -H "Content-type: application/json" -X POST -d "${json}" {{slack_webhook}}
