# We will need GPU access in these images,
# so base on nvidia/cuda, which is in turn
# based on centos:7.
FROM nvidia/cuda:9.1-cudnn7-devel-centos7

MAINTAINER Claudio Kopper <kopper@ualberta.ca>

# Make the nvidia tools available on the system in case we
# log intothe container through ssh
COPY nvidia.sh  /etc/profile.d/nvidia.sh
COPY nvidia.csh /etc/profile.d/nvidia.csh

# Enable OpenCL
RUN yum install -y epel-release && \
    yum install -y ocl-icd ocl-icd-devel clinfo && \
    rm -rf /var/cache/yum && \
    mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

# Install ssh, supervisord and ldap tools
RUN yum -y install openssh openssh-clients openssh-server && \
    mkdir -p /var/log/ssh && \
    mkdir -p /var/log/nslcd && \
    yum -y install epel-release && \
    yum -y install python-pip && \
    pip install supervisor supervisor-stdout && \
    yum -y install openldap-clients nss-pam-ldapd authconfig && \
    yum -y clean all && rm -rf /var/cache/yum && rm -rf /root/.cache

# Install compilers and other tools
RUN yum -y groups mark convert && \
    yum -y grouplist && \
    yum -y groupinstall \
           "Compatibility Libraries" \
           "Development Tools" \
           "Scientific Support" && \
    yum -y install nano astropy-tools bc binutils binutils-devel coreutils \
           curl fontconfig gcc gcc-c++ gcc-gfortran git glew-devel glib2-devel \
           glib-devel graphviz gsl-devel java-1.8.0-openjdk java-1.8.0-openjdk-devel \
           libgfortran libGLU libgomp libicu libquadmath libtool libtool-ltdl \
           libtool-ltdl-devel libX11-devel libXaw-devel libXext-devel \
           libXft-devel libxml2 libxml2-devel libXmu-devel libXpm libXpm-devel \
           libXt mesa-libGL-devel numpy octave octave-devel openssl098e p7zip \
           p7zip-plugins python-astropy python-devel R-devel redhat-lsb-core \
           rsync scipy subversion tcl-devel tcsh time tk-devel wget which \
           lzo squashfs-tools mc python-requests tmux screen mosh strace emacs \
           postgresql mariadb python2-pg8000 PyGreSQL valgrind cronie && \
    yum -y clean all && rm -rf /var/cache/yum

# Install Singularity (in directory-mode only, no loopback mounted images for now,
# those do not work well in docker [or need many more privileges...])
#COPY --from=singularity_builder /root/rpmbuild/RPMS/x86_64/singularity-*.rpm /root/
COPY singularity-*.rpm /root/
RUN yum -y install /root/singularity-*.rpm && \
    rm -rf /root/singularity-* && \
    sed -i 's/^[# ]*max loop devices.*/max loop devices = 0/g' /etc/singularity/singularity.conf && \
    sed -i 's/^[# ]*enable overlay.*/enable overlay = yes/g' /etc/singularity/singularity.conf && \
    sed -i 's/^[# ]*allow container squashfs.*/allow container squashfs = no/g' /etc/singularity/singularity.conf && \
    sed -i 's/^[# ]*allow container extfs.*/allow container extfs = no/g' /etc/singularity/singularity.conf && \
    sed -i 's/^[# ]*allow container dir.*/allow container dir = yes/g' /etc/singularity/singularity.conf && \
    yum -y clean all && rm -rf /var/cache/yum
