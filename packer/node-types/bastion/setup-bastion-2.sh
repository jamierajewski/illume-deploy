#!/bin/bash 

set -ex

#### Bastion Node VM - Part 2 (Following reboot) ###
# Produces the Bastion VM
# Author: Jamie Rajewski
################################

### DEFINE SOFTWARE VERSIONS HERE ###
RKE_V="1.1.7"
KUBECTL_V="1.19.1"

# 3.9 Check that Docker works without sudo
docker run hello-world
docker rmi -f hello-world

# 4. Kubectl - Works within 1 major version of k8s (so 1.19 will work with 1.18)
curl -LO "https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_V}/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
# Test to make sure it works
kubectl version --client

# 5. RKE - This version supports k8s 1.18.8 as the latest
wget "https://github.com/rancher/rke/releases/download/v${RKE_V}/rke_linux-amd64"
sudo mv rke_linux-amd64 /usr/local/bin/rke
chmod +x /usr/local/bin/rke


