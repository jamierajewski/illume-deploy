FROM centos:7

MAINTAINER Claudio Kopper <kopper@ualberta.ca>

# Install condor
RUN yum -y install wget && \
    cd /etc/yum.repos.d && wget http://research.cs.wisc.edu/htcondor/yum/repo.d/htcondor-stable-rhel7.repo && \
    wget http://research.cs.wisc.edu/htcondor/yum/RPM-GPG-KEY-HTCondor && rpm --import RPM-GPG-KEY-HTCondor && \
    yum -y install condor && \
    yum -y clean all && rm -rf /var/cache/yum

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
