#!/bin/bash

TF_PLAN=illume.tfplan

terraform validate || exit 1
terraform init || exit 2
terraform plan -out $TF_PLAN|| exit 3
terraform apply $TF_PLAN || exit 4
#./create_config.py || exit 5
#rke up || exit 6
#echo Kubernetes-Cluster is running.
