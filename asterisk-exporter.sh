#!/bin/bash

#########################################################
#
# Asterisk Exporter for Prometheus - Ubuntu (systemd)
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

export DEBIAN_FRONTEND=noninteractive

apt install -y tar wget python3 python3-pip
pip3 install prometheus

cd /tmp
wget https://github.com/khankawais/how-to-install-exporter-monitor-with-prometheus-and-grafana/archive/0.1.tar.gz
tar xvf 0.1.tar.gz
cd how-to-install-exporter-monitor-with-prometheus-and-grafana-0.1/asterisk_exporter/
cp asterisk_exporter.py /usr/local/bin/asterisk_exporter.py
rm -rf xvf 0.1.tar.gz how-to-install-exporter-monitor-with-prometheus-and-grafana-0.1

cat << EOF > /etc/systemd/system/asterisk_exporter.service
[Unit]
Description=Asterisk exporter metrics monitor calls
Wants=network-online.target
After=network-online.target
[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/local/bin/asterisk_exporter.py
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start asterisk_exporter
systemctl enable asterisk_exporter

# journalctl -f -u asterisk_exporter.service    - To make sure everything is running smoothly :)   -f = follow | -u = Unit

#-- Add prometheus scrape target --- /etc/prometheus/prometheus.yml
# 
#   - job_name: asterisk
#     static_configs:
#       - targets: ['10.0.0.121:9200']
