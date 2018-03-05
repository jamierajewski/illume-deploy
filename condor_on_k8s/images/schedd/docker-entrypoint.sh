#!/bin/bash

# HTCondor Configuration
echo "CONDOR_HOST = $CONDOR_HOST" > /etc/condor/config.d/docker
echo "SEC_PASSWORD_FILE = $SEC_PASSWORD_FILE" >> /etc/condor/config.d/docker

# configure
/usr/sbin/authconfig --enableldap --enableldapauth --ldapserver=$LDAP_SERVER --ldapbasedn=$LDAP_BASEDN --enableforcelegacy --enablemkhomedir --update

# install ssh host keys
cp /etc/ssh-host-keys/ssh_host_* /etc/ssh/
chmod 600 /etc/ssh/ssh_host_*
chmod 644 /etc/ssh/ssh_host_*.pub

exec /usr/bin/supervisord -c /etc/supervisord.conf
