#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y curl

cat /home/vagrant/.ssh/me.pub >> /home/vagrant/.ssh/authorized_keys
mkdir -p /root/.ssh
cat /home/vagrant/.ssh/me.pub >> /root/.ssh/authorized_keys


# Set up K3s worker
export K3S_URL="https://192.168.56.110:6443"
export K3S_TOKEN=$(cat /vagrant/node-token)
export INSTALL_K3S_EXEC="agent --node-ip=192.168.56.111 --flannel-iface=eth1"

# Install K3s agent
curl -sfL https://get.k3s.io | sh -