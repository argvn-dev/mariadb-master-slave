#!/bin/bash

if [ -z "$1" ]; then
  read -s -p "Password root MySQL: " MYSQL_ROOT_PASS
  echo
else
  MYSQL_ROOT_PASS="$1"
fi

apt update
apt install -y wget curl

wget https://github.com/openark/orchestrator/releases/download/v3.2.6/orchestrator_3.2.6_amd64.deb
dpkg -i orchestrator_3.2.6_amd64.deb

mkdir -p /etc/orchestrator

cat > /etc/orchestrator/orchestrator.conf.json <<EOF
{
  "Debug": false,
  "MySQLOrchestratorHost": "127.0.0.1",
  "MySQLOrchestratorPort": 3306,
  "MySQLOrchestratorUser": "root",
  "MySQLOrchestratorPassword": "$MYSQL_ROOT_PASS",
  "RaftEnabled": false
}
EOF
