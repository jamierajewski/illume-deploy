#!/bin/sh

# HTCondor configuration

NUM_CPUS=$(echo $CPU_LIMIT | awk '{x=$1; print( (x == int(x)) ? x : int(x)+1)}')
MEM_AVAILABLE=$(echo $MEM_LIMIT | awk '{print int($1)/1024/1024}')

echo "configuring for $NUM_CPUS CPUs with $MEM_AVAILABLE MiB of memory"
echo "NUM_SLOTS=1" > /etc/condor/config.d/slot
echo "NUM_SLOTS_TYPE_1=1" >> /etc/condor/config.d/slot
echo "SLOT_TYPE_1=cpus=$NUM_CPUS,ram=$MEM_AVAILABLE,auto" >> /etc/condor/config.d/slot
echo "SLOT_TYPE_1_PARTITIONABLE=TRUE" >> /etc/condor/config.d/slot

echo "CONDOR_HOST = $CONDOR_HOST" >> /etc/condor/config.d/docker
echo "SEC_PASSWORD_FILE = $SEC_PASSWORD_FILE" >> /etc/condor/config.d/docker
echo "EXECUTE = $CONDOR_SCRATCH" >> /etc/condor/config.d/docker

chown -R condor:condor $CONDOR_SCRATCH

# configure
/usr/sbin/authconfig --enableldap --enableldapauth --ldapserver=$LDAP_SERVER --ldapbasedn=$LDAP_BASEDN --enableforcelegacy --enablemkhomedir --update

exec /usr/bin/supervisord -c /etc/supervisord.conf
