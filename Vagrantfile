# -*- mode: ruby -*-
# vi: set ft=ruby :

boxes = [
  { :name => :nimbus, :ip => '10.110.55.40', :cpus =>2, :memory => 512, :instance => 'm1.small' },
  { :name => :supervisor1, :ip => '10.110.55.41', :cpus =>4, :memory => 1024, :instance => 'm1.medium' },
  { :name => :supervisor2, :ip => '10.110.55.42', :cpus =>4, :memory => 1024, :instance => 'm1.medium' },
  { :name => :zookeeper1, :ip => '10.110.55.46', :cpus =>1, :memory => 1024, :instance => 'm1.small' },
]

AWS_REGION = ENV['AWS_REGION'] || "ap-southeast-2"
AWS_AMI    = ENV['AWS_AMI']    || "ami-97e675ad"

Vagrant.configure("2") do |config|

  boxes.each do |opts|
  	config.vm.define opts[:name] do |config|
  	  
      config.vm.hostname = "storm.%s" % opts[:name].to_s   			
      config.vm.synced_folder "./data", "/vagrant_data"
      
      config.vm.provider :aws do |aws, override|
        config.vm.box = "dummy"
    	aws.access_key_id = ""
    	aws.secret_access_key = ""
    	aws.keypair_name = ""
    	aws.region = AWS_REGION
    	aws.ami    = AWS_AMI
    	aws.private_ip_address = opts[:ip]
		aws.subnet_id = "" 
    	override.ssh.username = "ubuntu"
    	override.ssh.private_key_path = ""
    	aws.instance_type = opts[:instance]
  	  end
      
      config.vm.provider :virtualbox do |vb|
      	config.vm.box = "trusty64"
   	    config.vm.box_url = "http://files.vagrantup.com/trusty64.box"
        config.vm.network :private_network, ip: opts[:ip]
        vb.name = "storm.%s" % opts[:name].to_s
        vb.customize ["modifyvm", :id, "--memory", opts[:memory]]
        vb.customize ["modifyvm", :id, "--cpus", opts[:cpus] ] if opts[:cpus]
      end
      
      config.vm.provider :lxc do |vb|
      	config.vm.box = "fgrehm/trusty64-lxc"
        config.vm.network :private_network, ip: opts[:ip]
        lxc.container_name = config.vm.hostname
        lxc.customize 'cgroup.memory.limit_in_bytes', opts[:memory].to_s + "M"
      end

      config.vm.provision :shell, :inline => "hostname storm.%s" % opts[:name].to_s
      config.vm.provision :shell, :inline => "cp -fv /vagrant_data/hosts /etc/hosts"
      config.vm.provision :shell, :inline => "apt-get update"
      config.vm.provision :shell, :inline => "apt-get --yes --force-yes install puppet"
      
      config.vm.provision :puppet do |puppet|
    	puppet.manifests_path = "manifests"
    	puppet.manifest_file = "provision.pp"
  	  end
  	  
  	  # Ask puppet to do the provisioning now.
  	  config.vm.provision :shell, :inline => "puppet apply /tmp/storm-puppet/manifests/site.pp --verbose --modulepath=/tmp/storm-puppet/modules/ --debug"	
      
    end
  end
end
