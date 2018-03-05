FROM illumecluster/base-system-centos7:latest

MAINTAINER Claudio Kopper <kopper@ualberta.ca>

ENV TINI_VERSION v0.17.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini
RUN chmod +x /sbin/tini

COPY condor_config.local /etc/condor/
COPY worker /etc/condor/config.d/

COPY supervisord.conf /etc/supervisord.conf
COPY docker-entrypoint.sh /

ENV CPU_LIMIT=1 \
    MEM_LIMIT=1073741824

ENTRYPOINT ["/sbin/tini", "--", "/docker-entrypoint.sh"]
