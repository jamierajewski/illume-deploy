#!/bin/bash 

set -ex

#### Worker Node Provisioner ###
# Gets run within the Terraform configuration for the worker node
# Author: Jamie Rajewski
################################

### DEFINE SOFTWARE VERSIONS HERE ###

### MAKE SURE ALL CUSTOM SCRIPTS AND STEPS FROM ANSIBLE ARE ADDED IN

# 1. Update/dist-upgrade
sudo apt-get update -y
sudo apt-get dist-upgrade -y

# 2. Dependencies
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common \
     curl wget git
     
# 3. Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update -y
apt-cache policy docker-ce
sudo apt install -y docker-ce
sudo usermod -aG docker ${USER}
# Need to reboot VM here for docker group change to take effect

# 4. Enable Docker Rootless

# 5. Nvidia Drivers/CUDA
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/11.0.3/local_installers/cuda-repo-ubuntu2004-11-0-local_11.0.3-450.51.06-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2004-11-0-local_11.0.3-450.51.06-1_amd64.deb
sudo apt-key add /var/cuda-repo-ubuntu2004-11-0-local/7fa2af80.pub
sudo apt-get update -y
sudo apt-get install -y cuda

# 6. Nvidia Container Runtime
curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list
sudo apt-get update -y
sudo apt-get install -y nvidia-container-runtime

# 7. CVMFS - Does that go here or later?
