#!/bin/bash 

set -ex

# Common across all nodes

# 1. Update/dist-upgrade
sudo apt-get update -y
sudo apt-get dist-upgrade -y

# 2. Dependencies
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common \
     curl wget git