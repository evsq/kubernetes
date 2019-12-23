#!/bin/bash

# Download and extract node_exporter files
curl -LO https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz
tar xvzf node_exporter-0.18.1.linux-amd64.tar.gz

# Copy node_exporter bin
cp node_exporter-0.18.1.linux-amd64/node_exporter /usr/bin/

# Create node_exporter user
useradd -s /sbin/nologin nexporter

# Create node_exporter systemd unit
cat <<EOF > /lib/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=nexporter
Group=nexporter
Type=simple
ExecStart=/usr/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Start service
systemctl daemon-reload
systemctl enable --now node_exporter
