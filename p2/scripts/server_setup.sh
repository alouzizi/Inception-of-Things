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
  --advertise-address=192.168.56.110" sh -


# Create Docker Hub credentials secret
sudo k3s kubectl create secret docker-registry dockerhub-secret \
  --docker-username="its0me" \
  --docker-password="\$\$aDocker\$\$12" \


# apply the configurations
 sudo kubectl apply -f ./confs/app1-myportfolio.yaml
 sudo kubectl apply -f ./confs/app2-myportfolio.yaml
 sudo kubectl apply -f ./confs/app3-myportfolio.yaml
 sudo kubectl apply -f ./confs/ingress.yaml
