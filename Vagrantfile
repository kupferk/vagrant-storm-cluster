# -*- mode: ruby -*-
# vi: set ft=ruby :

boxes = [
  { :name => :nimbus, :ip => '10.110.55.40', :cpus =>2, :memory => 512, :instance => 'm1.small', :mac => '00:16:3e:33:44:40' },
  { :name => :supervisor1, :ip => '10.110.55.41', :cpus =>4, :memory => 1024, :instance => 'm1.medium', :mac => '00:16:3e:33:44:41' },
  { :name => :supervisor2, :ip => '10.110.55.42', :cpus =>4, :memory => 1024, :instance => 'm1.medium', :mac => '00:16:3e:33:44:42' },
  { :name => :zookeeper1, :ip => '10.110.55.46', :cpus =>1, :memory => 1024, :instance => 'm1.small', :mac => '00:16:3e:33:44:46' },
]

AWS_REGION = ENV['AWS_REGION'] || "ap-southeast-2"
AWS_AMI    = ENV['AWS_AMI']    || "ami-97e675ad"
LXC_BRIDGE = 'lxcbr0'


Vagrant.configure("2") do |config|

  boxes.each do |opts|
  	config.vm.define opts[:name] do |node|
  	  
      node.vm.hostname = opts[:name].to_s
  	  node.vm.box = "trusty64"
      node.vm.box_url = "http://files.vagrantup.com/trusty64.box"
      
      node.vm.provider :aws do |aws, override|
        override.vm.box = "dummy"
    	override.ssh.username = "ubuntu"
    	override.ssh.private_key_path = ""
    	aws.access_key_id = ""
    	aws.secret_access_key = ""
    	aws.keypair_name = ""
    	aws.region = AWS_REGION
    	aws.ami    = AWS_AMI
    	aws.private_ip_address = opts[:ip]
		aws.subnet_id = "" 
    	aws.instance_type = opts[:instance]
  	  end
      
      node.vm.provider :virtualbox do |vb, override|
        override.vm.network :private_network, ip: opts[:ip]
        vb.name = "storm.%s" % opts[:name].to_s
        vb.customize ["modifyvm", :id, "--memory", opts[:memory]]
        vb.customize ["modifyvm", :id, "--cpus", opts[:cpus] ] if opts[:cpus]
      end
      
      node.vm.provider :lxc do |lxc, override|
      	override.vm.box = "fgrehm/trusty64-lxc"
   	    override.vm.box_url = "https://atlas.hashicorp.com/fgrehm/boxes/trusty64-lxc/versions/1.2.0/providers/lxc.box"
        # override.vm.network :private_network, ip: opts[:ip], lxc__bridge_name: LXC_BRIDGE
        lxc.container_name = "storm.%s" % opts[:name].to_s
        lxc.customize 'cgroup.memory.limit_in_bytes', opts[:memory].to_s + "M"
        lxc.customize 'network.type', 'veth'
        lxc.customize 'network.link', LXC_BRIDGE
        lxc.customize 'network.hwaddr', opts[:mac].to_s
      end

      node.vm.provision :shell, :inline => "hostname %s" % opts[:name].to_s
      node.vm.provision :shell, :inline => "cp -fv /vagrant/provision/data/hosts /etc/hosts"
      node.vm.provision :shell, :inline => "apt-get update"
      node.vm.provision :shell, :inline => "apt-get --yes --force-yes install puppet"

      # install librarian-puppet and run it to install puppet common modules.
      # This has to be done before puppet provisioning so that modules are available
      # when puppet tries to parse its manifests
      config.vm.provision :shell, :path => "provision/scripts/main.sh"
      
      node.vm.provision :puppet do |puppet|
    	puppet.manifests_path = "provision/puppet/manifests"
        puppet.manifest_file = 'site.pp'
        puppet.module_path = [ 'provision/puppet/modules-contrib', 'provision/puppet/modules' ]
        puppet.options = "--verbose --debug"
  	  end
    end
  end
end

