FROM centos:7

MAINTAINER Claudio Kopper <kopper@ualberta.ca>

# Install condor
RUN yum -y install wget python-requests && \
    cd /etc/yum.repos.d && wget http://research.cs.wisc.edu/htcondor/yum/repo.d/htcondor-stable-rhel7.repo && \
    wget http://research.cs.wisc.edu/htcondor/yum/RPM-GPG-KEY-HTCondor && rpm --import RPM-GPG-KEY-HTCondor && \
    yum -y install condor && \
    yum -y clean all && rm -rf /var/cache/yum

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
    yum -y groupinstall "Compatibility Libraries" "Development Tools" "Scientific Support" && \
    yum -y install nano astropy-tools bc binutils binutils-devel coreutils \
           curl fontconfig gcc gcc-c++ gcc-gfortran git glew-devel glib2-devel \
           glib-devel graphviz gsl-devel java-1.8.0-openjdk java-1.8.0-openjdk-devel \
           libgfortran libGLU libgomp libicu libquadmath libtool libtool-ltdl \
           libtool-ltdl-devel libX11-devel libXaw-devel libXext-devel \
           libXft-devel libxml2 libxml2-devel libXmu-devel libXpm libXpm-devel \
           libXt mesa-libGL-devel numpy octave octave-devel openssl098e p7zip \
           p7zip-plugins python-astropy python-devel R-devel redhat-lsb-core \
           rsync scipy subversion tcl-devel tcsh time tk-devel wget which \
           lzo squashfs-tools mc && \
    yum -y clean all && rm -rf /var/cache/yum

# Install Singularity (in directory-mode only, no loopback mounted images right now,
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
