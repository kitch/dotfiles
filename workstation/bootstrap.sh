#!/bin/bash

set -eu

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y

apt-get install -qq -y \
  docker.io \
  openssh-server

echo "Creating directories"
mkdir -p /mnt/code /mnt/secrets

echo "=> Setting up devbox service"
cat > dockerdevbox.service <<EOF
[Unit]
Description=dockerdevbox
Requires=docker.service
After=docker.service

[Service]
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker kill devbox
ExecStartPre=-/usr/bin/docker rm devbox
ExecStartPre=/usr/bin/docker pull kitch/devbox:latest
ExecStart=/usr/bin/docker run -h dev -e TZ=UTC --net=host --rm -v /var/run/docker.sock:/var/run/docker.sock -v /mnt/code:/root/code -v /mnt/secrets:/root/secrets --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --privileged --name dev kitch/devbox:latest

[Install]
WantedBy=multi-user.target
EOF

sudo mv dockerdevbox.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable dockerdev
sudo systemctl start dockerdev

echo "Done!"
