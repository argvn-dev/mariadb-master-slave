#!/bin/bash

if [ -z "$1" ]; then
  read -s -p "Password root MySQL: " MYSQL_ROOT_PASS
  echo
else
  MYSQL_ROOT_PASS="$1"
fi

REPL_USER="$2"
REPL_PASSWORD="$3"
DB_NAME="$4"

if [ -z "$REPL_USER" ]; then
  read -p "Username replikasi: " REPL_USER
fi

if [ -z "$REPL_PASSWORD" ]; then
  read -s -p "Password replikasi: " REPL_PASSWORD
  echo
fi

if [ -z "$DB_NAME" ]; then
  read -p "Nama database: " DB_NAME
fi

cat >> /etc/my.cnf <<EOF

[mysqld]
server-id=1
log_bin=mysql-bin
binlog_format=ROW
binlog_do_db=$DB_NAME
EOF

systemctl restart mariadb

mysql -u root -p"$MYSQL_ROOT_PASS" -e "
CREATE USER '$REPL_USER'@'%' IDENTIFIED BY '$REPL_PASSWORD';
GRANT REPLICATION SLAVE ON *.* TO '$REPL_USER'@'%';
FLUSH PRIVILEGES;
FLUSH TABLES WITH READ LOCK;
SHOW MASTER STATUS;
"