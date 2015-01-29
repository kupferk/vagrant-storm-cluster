# This puppet file simply installs the required packages for provisioning and gets the base 
# provisioning from the correct repos. The VM can then provision itself from there. 

$CLONE_URL = "https://github.com/kupferk/storm-cluster-puppet.git"
$CHECKOUT_DIR="/tmp/storm-cluster-puppet"


$rubygems = $operatingsystem ? {
        Ubuntu  => "rubygems-integration",
        default => "rubygems",
}


package {git:ensure=> [latest,installed]}
package {puppet:ensure=> [latest,installed]}
package {ruby:ensure=> [latest,installed]}
package {unzip:ensure=> [latest,installed]}
package {$rubygems:ensure=> [latest,installed], alias=>"rubygems"}


exec { "install_hiera":
	command => "gem install hiera hiera-puppet",
    path => ["/bin","/usr/bin"],
    require => Package['rubygems'],
}

vcsrepo { "config":
    path     => "${CHECKOUT_DIR}",
	source   => "$CLONE_URL",
	revision => 'master',
	ensure   => latest,
    provider => git,
}
  
#exec {"/bin/ln -f -s /var/lib/gems/1.8/gems/hiera-puppet-1.0.0/ ${CHECKOUT_DIR}/modules/hiera-puppet":
#	creates => "${CHECKOUT_DIR}/modules/hiera-puppet",
#	require => [Exec['update_config'],Exec['install_hiera']]
#}


#install hiera and the storm configuration
file { "/etc/puppet/hiera.yaml":
    source => "/vagrant_data/hiera.yaml",
    replace => true,
    require => Package['puppet']
}

file { "/etc/puppet/hieradata":
	ensure => directory,
	require => Package['puppet'] 
}

file {"/etc/puppet/hieradata/storm.yaml": 
	source => "${CHECKOUT_DIR}/modules/storm.yaml",
    replace => true,
    require => [Vcsrepo['config'],File['/etc/puppet/hieradata']]
}

