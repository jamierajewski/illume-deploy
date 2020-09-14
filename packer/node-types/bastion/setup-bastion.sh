#!/bin/bash 

set -ex

#### Bastion Node VM ###
# Produces the Bastion VM
# Author: Jamie Rajewski
################################

### DEFINE SOFTWARE VERSIONS HERE ###
DOCKER_V="19.03.12"

# 0. Set the frontend to noninteractive
export DEBIAN_FRONTEND=noninteractive



# 3. Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update -y
apt-cache policy docker-ce
sudo apt install -y docker-ce

# 3.5 Create Docker group
sudo groupadd docker
sudo usermod -aG docker $USER

# Need to reboot VM here for docker group change to take effect
sudo reboot
