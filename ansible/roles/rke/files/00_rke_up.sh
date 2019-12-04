#!/bin/sh

cd ~/
rke up
mkdir ~/.kube
cp ~/kube_config_cluster.yml ~/.kube/config

