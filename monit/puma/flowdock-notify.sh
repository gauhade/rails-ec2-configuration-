hostname=$(hostname)
data="{ \"event\": \"message\", \"content\": \"[{{RAILS_ENV}}][$hostname] restarted puma process.\", \"external_user_name\": \"Monit\" }"
curl -i -X POST -H "Content-Type: application/json" -d "$data" https://api.flowdock.com/v1/messages/chat/{{flow_token}}
