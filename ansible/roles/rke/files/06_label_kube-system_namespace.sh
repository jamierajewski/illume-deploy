#!/bin/sh

# label the kube-system namespace so we can refer to it in our
# NetworkPolicy definitions
kubectl label namespace kube-system name=kube-system

