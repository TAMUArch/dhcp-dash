# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.berkshelf.enabled = true

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", 2048]
    v.customize ["modifyvm", :id, "--cpus", 2]
  end

  config.vm.network :forwarded_port, guest: 4567, host: 8080

  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "mongodb::10gen_repo"
    chef.add_recipe "mongodb"
  end
end