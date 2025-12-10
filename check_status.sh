#!/bin/bash

if [ -z "$1" ]; then
  read -s -p "Password root MySQL: " MYSQL_ROOT_PASS
  echo
else
  MYSQL_ROOT_PASS="$1"
fi

STATUS=$(mysql -u root -p"$MYSQL_ROOT_PASS" -sN -e "SHOW SLAVE STATUS\G")

if [[ -z "$STATUS" ]]; then
  echo '{"role": "MASTER", "status": "OK"}'
  exit 0
fi

IO_RUNNING=$(echo "$STATUS" | grep "Slave_IO_Running" | awk '{print $2}')
SQL_RUNNING=$(echo "$STATUS" | grep "Slave_SQL_Running" | awk '{print $2}')
SECONDS_BEHIND=$(echo "$STATUS" | grep "Seconds_Behind_Master" | awk '{print $2}')

if [[ "$IO_RUNNING" == "Yes" && "$SQL_RUNNING" == "Yes" ]]; then
  echo "{\"role\": \"REPLICA\", \"status\": \"OK\", \"lag\": \"$SECONDS_BEHIND\"}"
else
  echo "{\"role\": \"REPLICA\", \"status\": \"ERROR\", \"lag\": \"$SECONDS_BEHIND\"}"
fi
