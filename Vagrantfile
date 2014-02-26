# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "base"

  config.berkshelf.enabled = true

  config.vm.define "dhcp-server" do |srv|
    srv.vm.box = "ubuntu"

    srv.vm.network "private_network", ip: "10.10.10.2",
      virtualbox__intnet: true

    srv.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-12.04_chef-provisionerless.box"
    srv.omnibus.chef_version = :latest


    srv.vm.provision "chef_solo" do |chef|
      chef.add_recipe "dhcp"

      chef.json = {
        "dhcp" => {
          "option" => {
            "domain_name" => "dhcp_domain",
            "dns_servers" => "8.8.8.8"
          },
          "pool" => {
            "range" => "10.10.10.5 10.10.10.254",
            "mask" => "255.255.255.0",
            "network" => "10.10.10.0",
            "options" => "",
            "failover" => "failover-peer",
            "routers" => "10.10.10.4"
          }
        }
      }
    end
  end

=begin
  config.vm.define "node1" do |n1|
    n1.vm.box = "centos"
    n1.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.5_chef-provisionerless.box"
  end

  config.vm.define "node2" do |n2|
    n2.vm.box = "centos"
  end
=end
end
