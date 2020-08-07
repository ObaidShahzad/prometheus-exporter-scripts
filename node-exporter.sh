#!/bin/bash

##############################################3############
#
# Node Exporter for Prometheus - Ubuntu (systemd)
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

cd /tmp/
wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz
tar zxf node_exporter-0.18.1.linux-amd64.tar.gz
cd node_exporter-0.18.1.linux-amd64
cp node_exporter /usr/local/bin
useradd -rs /bin/false node_exporter    #  -r = create a system account |  -s = login shell of the new account
chown node_exporter:node_exporter /usr/local/bin/node_exporter  
rm -rf node_exporter-0.18.1.linux-amd64 node_exporter-0.18.1.linux-amd64.tar.gz
cat << EOF > /lib/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=node_exporter
Group=node_exporter
ExecStart=/usr/local/bin/node_exporter \
    --collector.mountstats \
    --collector.logind \
    --collector.processes \
    --collector.ntp \
    --collector.systemd \
    --collector.tcpstat \
    --collector.wifi

Restart=always

[Install]
WantedBy=multi-user.target
EOF
chmod 755 /lib/systemd/system/node_exporter.service
systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter
# journalctl -f -u node_exporter.service    - To make sure everything is running smoothly :)   -f = follow | -u = Unit

#-- Add prometheus scrape target --- /etc/prometheus/prometheus.yml
# 
#   - job_name: node
#     static_configs:
#       - targets: ['10.0.0.121:9100']