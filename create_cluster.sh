#!/bin/bash

TF_PLAN=illume.tfplan

cd terraform
terraform init || exit 1
terraform validate || exit 2
terraform plan -out $TF_PLAN -var-file=../openstack_user.tfvars || exit 3
terraform apply $TF_PLAN || exit 4
#./create_config.py || exit 5
#rke up || exit 6
#echo Kubernetes-Cluster is running.
