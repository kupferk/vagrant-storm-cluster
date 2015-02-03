#!/bin/bash
 
# Directory in which librarian-puppet should manage its modules directory
PUPPET_DIR=/vagrant/provision/puppet

cp -fv /vagrant/provision/data/hosts /etc/hosts
apt-get update
apt-get --yes --force-yes install puppet rubygems-integration

 
if [ "$(gem search -i librarian-puppet)" = "false" ]; then
  gem install librarian-puppet
  cd $PUPPET_DIR && librarian-puppet install
else
  cd $PUPPET_DIR && librarian-puppet update
fi

