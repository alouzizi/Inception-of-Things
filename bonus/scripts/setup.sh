#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Colors for output
GREEN='\033[0;32m'
BLEU='\033[0;34m'
NC='\033[0m'

echo_step() {
    echo -e "${BLEU}[+] $1${NC}"
}


# Update system
echo_step "Updating system packages..."
sudo apt-get update
sudo apt-get install -y curl 


# Install Docker if not present
echo_step "Installing Docker..."
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker


# Install kubectl
echo_step "Installing kubectl..."
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/



# Install K3D
echo_step "Installing K3D..."
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash


# Create K3D cluster
echo_step "Creating K3D cluster..."
k3d cluster create mycluster

# Install Git Lab
echo_step "Installing GitLab..."
sudo kubectl create namespace gitlab
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add gitlab https://charts.gitlab.io
helm search repo -l gitlab/gitlab


# sudo curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash
# sudo kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo
# sudo kubectl port-forward services/gitlab-nginx-ingress-controller 8082:443 -n gitlab --address="0.0.0.0" 2>&1 > /var/log/gitlab-webserver.log &

# Install Argo CD
echo_step "Installing Argo CD..."
sudo kubectl create namespace argocd
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait until the Argo CD server pod is running
while [[ $(sudo kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o jsonpath='{.items[0].status.phase}') != "Running" ]]; do
  echo_step "Waiting for Argo CD server pod to be in 'Running' status..."
  sleep 5
done

sleep 5
# Apply Argo CD application
echo_step "Applying Argo CD application..."
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/alouzizi/K3d-ArgoCd/refs/heads/master/application.yaml


# get password
echo_step "Retrieving Argo CD initial admin password..."
echo "Argo CD Initial Admin Password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"


# # Wait for Argo CD to be ready
# echo_step "Waiting for Argo CD to be ready..."
# kubectl wait --for=condition=available deployment -l "app.kubernetes.io/name=argocd-server" -n argocd --timeout=300s



# # Install Argo CD CLI
# echo_step "Installing Argo CD CLI..."
# curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
# chmod +x argocd-linux-amd64
# mv argocd-linux-amd64 /usr/local/bin/argocd

echo_step "Installation complete!"
echo_step "You can access Argo CD UI by port-forwarding:"
echo "kubectl port-forward -n argocd svc/argocd-server -n argocd 8080:443 --address 0.0.0.0"

# get machine ip
ip=$(hostname -I | awk '{print $1}')
echo "Then visit: https://$ip:8080"



#sudo helm upgrade --install gitlab gitlab/gitlab   --timeout 600s   --set global.hosts.domain=localhost   --set global.hosts.externalIP=127.0.0.1   --set certmanager-issuer.email=me@example.com