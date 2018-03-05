#!/bin/sh

### Preparing the pool password
#We will use a pool password (i.e. shared secret) to secure the HTCondor cluster.
#Create a random pool password with filename `password` in the `/tmp` directory:
#```
docker run --rm -it -v /tmp:/vol illumecluster/htcondor-generate-password:latest
#```
#This will create a file `/tmp/password`. Create a secret from this new pool password:
#```
kubectl create secret generic --namespace=illume htcondor-pool-password --from-file=/tmp/password
sudo rm /tmp/password
#```
