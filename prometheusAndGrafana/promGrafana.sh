#!/bin/bash

# Download and extract prometheus files
curl -L https://github.com/prometheus/prometheus/releases/download/v2.10.0/prometheus-2.10.0.linux-amd64.tar.gz > prom.tar.gz
tar xvfz prom.tar.gz
mv prometheus-2.10.0.linux-amd64/ prometheus

# Create user and change permission on folder
useradd -s /sbin/nologin prometheus
chown -R prometheus:prometheus prometheus

# Create directories and change permissions on folders
mkdir /etc/prometheus
mkdir /var/lib/prometheus
chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

# Copy binaries and files
cd prometheus
cp prometheus promtool /usr/local/bin
cp -r consoles/ console_libraries/ /etc/prometheus/

# Add ip addresses your nodes in /etc/hosts
cat <<EOF >> /etc/hosts
10.5.0.10  kube-state-metrics
10.5.0.11  kube-state-metrics
10.5.0.12  kube-state-metrics
EOF

# Create configuration for prometheus, change your ip addresses for targets in jobs
cat <<EOF > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: 'prometheus_master'
    scrape_interval: 5s
    static_configs:
      - targets: ['10.5.0.10:9100']
  - job_name: 'etcd'
    scheme: https
    tls_config:
      ca_file: /etc/prometheus/etcd/etcd-ca.crt
      cert_file: /etc/prometheus/etcd/etcd.crt
      key_file: /etc/prometheus/etcd/etcd.key
    scrape_interval: 5s
    static_configs:
      - targets: ['10.5.0.10:2379']
  - job_name: 'prometheus_slave'
    scrape_interval: 5s
    static_configs:
      - targets: ['10.5.0.11:9100', '10.5.0.12:9100']
  - job_name: 'prometheus_kube_state_metrics'
    scrape_interval: 5s
    static_configs:
      - targets: ['kube-state-metrics:9100']
EOF

# Create prometheus systemd unit
cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

# Start service
systemctl daemon-reload
systemctl enable --now prometheus

# Check access
# http://localhost:9090/graph


# Grafana

# Add repo for grafana
cat <<EOF > /etc/yum.repos.d/grafana.repo
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF

# Install grafana
yum install grafana -y

# Start service
systemctl daemon-reload
systemctl enable --now grafana-server

# Check access
# http://localhost:3000/.
