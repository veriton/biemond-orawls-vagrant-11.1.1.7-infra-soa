# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # TODO insecure
  config.ssh.insert_key = false

  config.vm.define "soa2admin2" , primary: true do |soa2admin2|

    soa2admin2.vm.box = "centos-6.6-x86_64"
    soa2admin2.vm.box_url = "https://dl.dropboxusercontent.com/s/ijt3ppej789liyp/centos-6.6-x86_64.box"

    soa2admin2.vm.provider :vmware_fusion do |v, override|
      override.vm.box = "OEL-6.6-x86_64-vmware"
      override.vm.box_url = "https://dl.dropboxusercontent.com/s/96qaaklh1ya6qnd/OEL6_6-x86_64-vmware.box?dl=0"
    end

    soa2admin2.vm.hostname = "soa2admin2.example.com"
    soa2admin2.vm.synced_folder ".", "/vagrant", :mount_options => ["dmode=777","fmode=777"]
    soa2admin2.vm.synced_folder "/media/11.1.1.7", "/software"

    soa2admin2.vm.network :private_network, ip: "10.10.10.21"

    soa2admin2.vm.provider :vmware_fusion do |vb|
      vb.vmx["numvcpus"] = "2"
      vb.vmx["memsize"] = "2548"
    end

    soa2admin2.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "2548"]
      vb.customize ["modifyvm", :id, "--name"  , "soa2admin2"]
      vb.customize ["modifyvm", :id, "--cpus"  , 2]
    end

    soa2admin2.vm.provision :shell, :inline => "ln -sf /vagrant/puppet/hiera.yaml /etc/puppet/hiera.yaml;rm -rf /etc/puppet/modules;ln -sf /vagrant/puppet/modules /etc/puppet/modules"

    soa2admin2.vm.provision :puppet do |puppet|
      puppet.manifests_path    = "puppet/manifests"
      puppet.module_path       = "puppet/modules"
      puppet.manifest_file     = "site.pp"
      puppet.options           = "--verbose --strict_variables --hiera_config /vagrant/puppet/hiera.yaml"

      puppet.facter = {
        "environment"    => "development",
        "vm_type"        => "vagrant",
      }

    end

  end

  config.vm.define "soadb" , primary: true do |soadb|

    soadb.vm.box = "centos-6.6-x86_64"
    soadb.vm.box_url = "https://dl.dropboxusercontent.com/s/ijt3ppej789liyp/centos-6.6-x86_64.box"

    soadb.vm.provider :vmware_fusion do |v, override|
      override.vm.box = "OEL-6.6-x86_64-vmware"
      override.vm.box_url = "https://dl.dropboxusercontent.com/s/96qaaklh1ya6qnd/OEL6_6-x86_64-vmware.box?dl=0"
    end

    soadb.vm.hostname = "soadb.example.com"
    soadb.vm.synced_folder ".", "/vagrant", :mount_options => ["dmode=777","fmode=777"]
    soadb.vm.synced_folder "/media/11.1.1.7", "/software"

    soadb.vm.network :private_network, ip: "10.10.10.5"

    soadb.vm.provider :vmware_fusion do |vb|
      vb.vmx["numvcpus"] = "2"
      vb.vmx["memsize"] = "2548"
    end

    soadb.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm"     , :id, "--memory", "2548"]
      vb.customize ["modifyvm"     , :id, "--name"  , "soadb"]
      vb.customize ["modifyvm"     , :id, "--cpus"  , 2]
    end

    soadb.vm.provision :shell, :inline => "ln -sf /vagrant/puppet/hiera.yaml /etc/puppet/hiera.yaml;rm -rf /etc/puppet/modules;ln -sf /vagrant/puppet/modules /etc/puppet/modules"

    soadb.vm.provision :puppet do |puppet|
      puppet.manifests_path    = "puppet/manifests"
      puppet.module_path       = "puppet/modules"
      puppet.manifest_file     = "db.pp"
      puppet.options           = "--verbose --strict_variables --hiera_config /vagrant/puppet/hiera.yaml"
      # TODO need to define 
      puppet.options           = "--verbose --strict_variables --hiera_config /vagrant/puppet/hiera.yaml"

      puppet.facter = {
        "environment" => "development",
        "vm_type"     => "vagrant",
      }

    end

  end

end
