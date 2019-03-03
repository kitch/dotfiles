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
ExecStart=/usr/bin/docker run -h dev -e TZ=UTC --net=host --rm -v /var/run/docker.sock:/var/run/docker.sock -v /mnt/code:/root/code -v /mnt/secrets:/root/secrets -v /home/jakekit/debox/id_rsa:/root/.ssh/github_rsa -v /home/jakekit/devbox/id_rsa:/root/.ssh/id_rsa -v /home/jakekit/devbox/zhistory:/root/.zsh_history --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --privileged --name devbox kitch/devbox:latest
ExecStop=~/usr/bin/docker rm -f devbox

[Install]
WantedBy=multi-user.target
EOF

sudo mv dockerdevbox.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable dockerdevbox
sudo systemctl start dockerdevbox

echo "Done!"
