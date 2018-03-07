#!/bin/bash

cd terraform
terraform destroy -var-file=../openstack_user.tfvars || exit 1
