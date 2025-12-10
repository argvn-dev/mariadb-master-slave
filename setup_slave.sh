#!/bin/bash

if [ -z "$1" ]; then
  read -s -p "Password root MySQL: " MYSQL_ROOT_PASS
  echo
else
  MYSQL_ROOT_PASS="$1"
fi

MASTER_IP="$2"
MASTER_LOG_FILE="$3"
MASTER_LOG_POS="$4"

if [ -z "$MASTER_IP" ]; then
  echo "Error: MASTER_IP belum diisi."
  exit 1
fi

cat >> /etc/my.cnf <<EOF

[mysqld]
server-id=2
relay_log=relay-bin
EOF

systemctl restart mariadb

mysql -u root -p"$MYSQL_ROOT_PASS" -e "
STOP SLAVE;
CHANGE MASTER TO
  MASTER_HOST='$MASTER_IP',
  MASTER_USER='repl',
  MASTER_PASSWORD='replpassword',
  MASTER_LOG_FILE='$MASTER_LOG_FILE',
  MASTER_LOG_POS=$MASTER_LOG_POS;
START SLAVE;
SHOW SLAVE STATUS\G
"