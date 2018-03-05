FROM illumecluster/base-system-centos7:latest

MAINTAINER Claudio Kopper <kopper@ualberta.ca>

ENV TINI_VERSION v0.17.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini
RUN chmod +x /sbin/tini

COPY sshd_config /etc/ssh/sshd_config
COPY condor_config.local /etc/condor/
COPY schedd /etc/condor/config.d/
COPY htcondor-schedd-liveness /usr/local/bin/
COPY supervisord.conf /etc/supervisord.conf
COPY docker-entrypoint.sh /

ENTRYPOINT ["/sbin/tini", "--", "/docker-entrypoint.sh"]
