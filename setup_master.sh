#!/bin/bash

if [ -z "$1" ]; then
  read -s -p "Password root MySQL: " MYSQL_ROOT_PASS
  echo
else
  MYSQL_ROOT_PASS="$1"
fi

cat >> /etc/my.cnf <<EOF

[mysqld]
server-id=1
log_bin=mysql-bin
binlog_format=ROW
EOF

systemctl restart mariadb

mysql -u root -p"$MYSQL_ROOT_PASS" -e "
CREATE USER 'repl'@'%' IDENTIFIED BY 'replpassword';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;
FLUSH TABLES WITH READ LOCK;
SHOW MASTER STATUS;
"