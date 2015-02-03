# This puppet file simply installs the required packages for provisioning and gets the base 
# provisioning from the correct repos. The VM can then provision itself from there. 

package {puppet:ensure=> [latest,installed]}
package {ruby:ensure=> [latest,installed]}

# Make sure Java is installed on hosts, select specific version
class { 'java':
    distribution => 'jre'
}

# Modify global settings
class { 'storm': 
    version => '0.9.3',
    zookeeper_servers => ['zookeeper1'],
    drpc_servers => ['supervisor1', 'supervisor2'],
    nimbus_host => 'nimbus',
    supervisor_workers => '50'
}

node 'nimbus' {
  class { 'storm::nimbus': }
  class { 'storm::ui': }
}

node /supervisor[1-9]/ {
  class { 'storm::supervisor': }
}

node /zookeeper[1-9]/ {
  class { 'zookeeper': hostnames => [ $::fqdn ],  realm => '' }
}

