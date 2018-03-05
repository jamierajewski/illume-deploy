#!/bin/sh

# build singularity rpms and extract them
docker build -t temp_singularity_rpm images/singularity_rpm
docker create --name temp1 temp_singularity_rpm
docker cp temp1:/root/rpmbuild/RPMS/x86_64/singularity-2.4.2-1.el7.centos.x86_64.rpm images/base-system-centos7/
docker cp temp1:/root/rpmbuild/RPMS/x86_64/singularity-debuginfo-2.4.2-1.el7.centos.x86_64.rpm images/base-system-centos7/
docker cp temp1:/root/rpmbuild/RPMS/x86_64/singularity-devel-2.4.2-1.el7.centos.x86_64.rpm images/base-system-centos7/
docker cp temp1:/root/rpmbuild/RPMS/x86_64/singularity-runtime-2.4.2-1.el7.centos.x86_64.rpm images/base-system-centos7/
docker rm temp1

docker build -t illumecluster/base-system-centos7:latest images/base-system-centos7

docker build -t illumecluster/htcondor-worker:latest images/worker
docker build -t illumecluster/htcondor-schedd:latest images/schedd

docker build -t illumecluster/htcondor-generate-password:latest images/generate-password
docker build -t illumecluster/htcondor-negotiator:latest images/negotiator
docker build -t illumecluster/htcondor-collector:latest images/collector

docker login

docker push illumecluster/base-system-centos7:latest
docker push illumecluster/htcondor-worker:latest
docker push illumecluster/htcondor-schedd:latest
docker push illumecluster/htcondor-generate-password:latest
docker push illumecluster/htcondor-negotiator:latest
docker push illumecluster/htcondor-collector:latest
