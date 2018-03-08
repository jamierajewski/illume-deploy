#!/bin/sh

#### Preparing sshd keys
#Create the sshd host keys.
#```
ssh-keygen -t ed25519 -f /tmp/ssh_host_ed25519_key -N ""
ssh-keygen -t rsa -b 4096 -f /tmp/ssh_host_rsa_key -N ""
ssh-keygen -t ecdsa -f /tmp/ssh_host_ecdsa_key -N ""
#```
#
#Create new secrets from these keys
#```
kubectl create secret generic --namespace=illume ssh-host-keys --from-file=/tmp/ssh_host_ed25519_key --from-file=/tmp/ssh_host_ed25519_key.pub --from-file=/tmp/ssh_host_rsa_key --from-file=/tmp/ssh_host_rsa_key.pub --from-file=/tmp/ssh_host_ecdsa_key --from-file=/tmp/ssh_host_ecdsa_key.pub
rm /tmp/ssh_host_ed25519_key /tmp/ssh_host_ed25519_key.pub /tmp/ssh_host_rsa_key /tmp/ssh_host_rsa_key.pub /tmp/ssh_host_ecdsa_key /tmp/ssh_host_ecdsa_key.pub
#```
