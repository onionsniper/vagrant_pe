#!/bin/bash

# let's be verbose!
set -x

# the vagrant user has the same UID and GID as our admin/maintenance account
# let's update the vagrant UID & GID to avoid a conflict when puppet runs
/usr/bin/perl -i -pe 's/vagrant:x:1000:1000/vagrant:x:1007:1007/' /etc/passwd
/usr/sbin/groupmod -g 1007 vagrant
/bin/chown -R 1007:1007 /home/vagrant

# now, we apply a local puppet manifest to actually do the initial setup

VPUPPET=/opt/vagrant_ruby/bin/puppet
CONFDIR=/vagrant/puppet
MANIFEST=provision_master.pp

${VPUPPET} apply --confdir=${CONFDIR} -e 'host { "precisemaster": ip => "192.168.9.9", host_aliases => ["puppetmaster.vagrant","puppet.vagrant"] }'
${VPUPPET} apply --confdir=${CONFDIR} -e 'host { "precisenode1": ip => "192.168.10.10" }'
${VPUPPET} apply --confdir=${CONFDIR} -e 'host { "precisenode2": ip => "192.168.10.11" }'
${VPUPPET} apply --confdir=${CONFDIR} -e 'host { "lucidnode1": ip => "192.168.11.10" }'

${VPUPPET} apply --confdir=${CONFDIR} ${CONFDIR}/manifests/${MANIFEST}
