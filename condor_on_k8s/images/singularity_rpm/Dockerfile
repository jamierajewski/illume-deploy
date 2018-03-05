################# compile a singularity rpm ##################

FROM centos:7

# Install compilers and other tools
RUN yum -y groups mark convert && \
    yum -y grouplist && \
    yum -y groupinstall "Development Tools" && \
    yum -y install wget && \
    yum -y clean all && rm -rf /var/cache/yum

# Install Singularity (in directory-mode only, no loopback mounted images right now,
# those do not work well in docker [or need many more privileges...])
ENV SINGULARITY_VERSION=2.4.2
RUN wget https://github.com/singularityware/singularity/releases/download/$SINGULARITY_VERSION/singularity-$SINGULARITY_VERSION.tar.gz && \
    rpmbuild -ta singularity-$SINGULARITY_VERSION.tar.gz
