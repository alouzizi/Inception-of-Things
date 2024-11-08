#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y curl 

cat /home/vagrant/.ssh/me.pub >> /home/vagrant/.ssh/authorized_keys
mkdir -p /root/.ssh

cat /home/vagrant/.ssh/me.pub >> /root/.ssh/authorized_keys

# Install K3s server

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --node-ip=192.168.56.110 \
  --advertise-address=192.168.56.110 \
  --node-taint CriticalAddonsOnly=true:NoExecute" sh -


# Save token
cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token
chmod 644 /vagrant/node-token


# curl -sfL https://get.k3s.io | sh -s - server --node-taint CriticalAddonsOnly=true:NoExecute
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
