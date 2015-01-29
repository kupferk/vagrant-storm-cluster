

$JDK_VERSION = "1.6.0_35"
  
package {"openjdk":
	ensure  =>  absent,
} 
  
exec { "installJdk":
	command => "installJdk.sh",
    path => "/vagrant/scripts",
    logoutput => true, 
    creates => "/opt/jdk${JDK_VERSION}",
}

