#!/bin/bash

##############################################3############
#
# Apache Exporter for Prometheus - Ubuntu (systemd)
#
# note: run as root
#
# Author: Obaid Shahzad
# 
# Tested on: Ubuntu 18.04
#
# Dated: 8/6/2020
#
###########################################################

cd /tmp
wget https://github.com/Lusitaniae/apache_exporter/releases/download/v0.8.0/apache_exporter-0.8.0.linux-amd64.tar.gz
tar xvf apache_exporter-0.8.0.linux-amd64.tar.gz
cd apache_exporter-0.8.0.linux-amd64
cp apache_exporter /usr/local/bin
rm -rf apache_exporter-0.8.0.linux-amd64.tar.gz apache_exporter-0.8.0.linux-amd64
groupadd --system apache_exporter
useradd -s /bin/false -r -g apache_exporter apache_exporter

cat << EOF > /etc/systemd/system/apache_exporter.service
[Unit]
Description=Prometheus Apache Exporter
Wants=network.target
After=network.target
[Service]
User=apache_exporter
Group=apache_exporter
Type=simple
ExecStart=/usr/local/bin/apache_exporter
Restart=always
[Install]
WantedBy=multi-user.target
EOF

chmod 755 /etc/systemd/system/apache_exporter.service
systemctl daemon-reload
systemctl enable apache_exporter
systemctl start apache_exporter

# journalctl -f -u apache_exporter.service    - To make sure everything is running smoothly :)   -f = follow | -u = Unit

#-- Add prometheus scrape target --- /etc/prometheus/prometheus.yml
# 
#   - job_name: apache
#     static_configs:
#       - targets: ['10.0.0.121:9117']
