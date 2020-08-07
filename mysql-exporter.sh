#!/bin/bash

##########################################################
#
# MySQL Exporter for Prometheus - Ubuntu (systemd)
#
# note: run as root
#
# Author: Obaid Shahzad
# 
# Tested on: Ubuntu 18.04
#
# Dated: August 7, 2020
#
##########################################################

read -p "Enter MySQL database username: " mysql_user
read -p "Enter MySQL database password: " mysql_pass

export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y curl wget tar

curl -s https://api.github.com/repos/prometheus/mysqld_exporter/releases/latest   | grep browser_download_url   | grep linux-amd64 | cut -d '"' -f 4   | wget -i -
tar xvf mysqld_exporter*.tar.gz
cp /mysqld_exporter*/mysqld_exporter /usr/local/bin/
chmod +x /usr/local/bin/mysqld_exporter
groupadd --system mysql_exporter
useradd -s /sbin/nologin --system -g mysql_exporter mysql_exporter
rm -rf /mysqld_exporter*

cat << EOF > /tmp/commands.sql
   CREATE USER 'mysqld_exporter'@'localhost' IDENTIFIED BY 'prometheus' WITH MAX_USER_CONNECTIONS 2;
   GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'mysqld_exporter'@'localhost';
   FLUSH PRIVILEGES;
   EXIT
EOF
mysql -u $mysql_user --password=$mysql_pass < /tmp/commands.sql 
rm -rf /tmp/commands.sql

cat << EOF > /etc/.mysqld_exporter.cnf
[client]
user=mysqld_exporter
password=prometheus
host=localhost
EOF
chown root:mysql_exporter /etc/.mysqld_exporter.cnf

cat << EOF > /etc/systemd/system/mysql_exporter.service
[Unit]
 Description=Prometheus MySQL Exporter
 After=network.target
 User=mysql_exporter
 Group=mysql_exporter
 [Service]
 Type=simple
 Restart=always
 ExecStart=/usr/local/bin/mysqld_exporter \
 --config.my-cnf /etc/.mysqld_exporter.cnf \
 --collect.global_status \
 --collect.info_schema.innodb_metrics \
 --collect.auto_increment.columns \
 --collect.info_schema.processlist \
 --collect.binlog_size \
 --collect.info_schema.tablestats \
 --collect.global_variables \
 --collect.info_schema.query_response_time \
 --collect.info_schema.userstats \
 --collect.info_schema.tables \
 --collect.perf_schema.tablelocks \
 --collect.perf_schema.file_events \
 --collect.perf_schema.eventswaits \
 --collect.perf_schema.indexiowaits \
 --collect.perf_schema.tableiowaits \
 --collect.slave_status \
 --web.listen-address=0.0.0.0:9104
 
 [Install]
 WantedBy=multi-user.target
EOF

chown 755 /etc/systemd/system/mysql_exporter.service
systemctl daemon-reload
systemctl enable mysql_exporter
systemctl start mysql_exporter

# journalctl -f -u mysql_exporter.service    - To make sure everything is running smoothly :)   -f = follow | -u = Unit

#-- Add prometheus scrape target --- /etc/prometheus/prometheus.yml
# 
#   - job_name: mysql
#     static_configs:
#       - targets: ['10.0.0.121:9104']
