# This puppet file simply installs the required packages for provisioning and gets the base 
# provisioning from the correct repos. The VM can then provision itself from there. 

package {puppet:ensure=> [latest,installed]}
package {ruby:ensure=> [latest,installed]}


class { 'storm': 
    version => '0.9.3',
    zookeeper_servers => ['zookeeper1']
}

node 'nimbus' {
  class { 'storm::nimbus' }
  class { 'storm::ui' }
}

node /supervisor[1-9]/ {
  class { 'storm::supervisor' }
}

node /zookeeper[1-9]/ {
  class { 'zookeeper': hostnames => [ $::fqdn ],  realm => '' }
}

