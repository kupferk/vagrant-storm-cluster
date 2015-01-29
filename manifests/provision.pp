# This puppet file simply installs the required packages for provisioning and gets the base 
# provisioning from the correct repos. The VM can then provision itself from there. 

$CLONE_URL = "https://bitbucket.org/qanderson/storm-puppet.git"
$CHECKOUT_DIR="/tmp/storm-puppet"


package {git:ensure=> [latest,installed]}
package {puppet:ensure=> [latest,installed]}
package {ruby:ensure=> [latest,installed]}
package {rubygems:ensure=> [latest,installed]}
package {unzip:ensure=> [latest,installed]}

exec { "install_hiera":
	command => "gem install hiera hiera-puppet",
    path => "/usr/bin",
    require => Package['rubygems'],
}

exec { "clone_storm-puppet":
	command => "git clone ${CLONE_URL}",
	cwd => "/tmp",
    path => "/usr/bin",
    creates => "${CHECKOUT_DIR}",
    require => Package['git'],
}
  
exec {"/bin/ln -s /var/lib/gems/1.8/gems/hiera-puppet-1.0.0/ /tmp/storm-puppet/modules/hiera-puppet":
	creates => "/tmp/storm-puppet/modules/hiera-puppet",
	require => [Exec['clone_storm-puppet'],Exec['install_hiera']]
}


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
    require => [Exec['clone_storm-puppet'],File['/etc/puppet/hieradata']]
}

