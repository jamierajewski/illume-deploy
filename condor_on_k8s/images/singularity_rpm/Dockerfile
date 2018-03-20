################# compile a singularity rpm ##################

FROM centos:7

# Install compilers and other tools
RUN yum -y groups mark convert && \
    yum -y grouplist && \
    yum -y groupinstall "Development Tools" && \
    yum -y install wget && \
    yum -y clean all && rm -rf /var/cache/yum

# Build a singularity rpm package we can stage into the next image
ENV SINGULARITY_VERSION=2.4.2
RUN wget https://github.com/singularityware/singularity/releases/download/$SINGULARITY_VERSION/singularity-$SINGULARITY_VERSION.tar.gz && \
    rpmbuild -ta singularity-$SINGULARITY_VERSION.tar.gz
