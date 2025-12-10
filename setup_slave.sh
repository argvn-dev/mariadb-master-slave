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
REPL_USER="$5"
REPL_PASSWORD="$6"
DB_NAME="$7"

if [ -z "$MASTER_IP" ]; then
  echo "Error: MASTER_IP belum diisi."
  exit 1
fi

if [ -z "$REPL_PASSWORD" ]; then
  read -s -p "Password replikasi MySQL: " REPL_PASSWORD
  echo
fi

if [ -z "$REPL_USER" ]; then
  read -p "Username replikasi: " REPL_USER
fi

if [ -z "$DB_NAME" ]; then
  read -p "Nama database: " DB_NAME
fi

cat >> /etc/my.cnf <<EOF

[mysqld]
server-id=2
relay_log=relay-bin
replicate_do_db=$DB_NAME
EOF

systemctl restart mariadb

mysql -u root -p"$MYSQL_ROOT_PASS" -e "
STOP SLAVE;
CHANGE MASTER TO
  MASTER_HOST='$MASTER_IP',
  MASTER_USER='$REPL_USER',
  MASTER_PASSWORD='$REPL_PASSWORD',
  MASTER_LOG_FILE='$MASTER_LOG_FILE',
  MASTER_LOG_POS=$MASTER_LOG_POS;
START SLAVE;
SHOW SLAVE STATUS\G
"