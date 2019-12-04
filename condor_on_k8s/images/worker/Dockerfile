FROM illumecluster/base-system-centos7:latest

MAINTAINER Claudio Kopper <kopper@ualberta.ca>

ENV TINI_VERSION v0.17.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini

# Install condor
RUN chmod +x /sbin/tini && \
    yum -y install wget python-requests && \
    cd /etc/yum.repos.d && wget http://research.cs.wisc.edu/htcondor/yum/repo.d/htcondor-stable-rhel7.repo && \
    wget http://research.cs.wisc.edu/htcondor/yum/RPM-GPG-KEY-HTCondor && rpm --import RPM-GPG-KEY-HTCondor && \
    yum -y install condor && \
    yum -y clean all && rm -rf /var/cache/yum

COPY condor_config.local /etc/condor/
COPY worker /etc/condor/config.d/

COPY supervisord.conf /etc/supervisord.conf
COPY docker-entrypoint.sh /

ENV CPU_LIMIT=1 \
    MEM_LIMIT=1073741824

ENTRYPOINT ["/sbin/tini", "--", "/docker-entrypoint.sh"]
