#!/bin/sh

kubectl run --rm -ti --image=ubuntu --limits='nvidia.com/gpu=1' ubuntu nvidia-smi
