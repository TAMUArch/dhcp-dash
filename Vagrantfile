# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
DOMAIN_NAME = "test_domain"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "base"

  config.berkshelf.enabled = true

  config.vm.define "dhcp-server" do |srv|
    srv.vm.box = "centos"
    srv.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.5_chef-provisionerless.box"

    srv.vm.host_name = "dhcp-server"
    srv.vm.network "private_network", ip: "10.10.10.2"

    srv.vm.network :forwarded_port, guest: 4567, host: 4567
    srv.vm.synced_folder ".", "/opt/dhcp-dash"

    srv.omnibus.chef_version = :latest
    srv.vm.provision "chef_solo" do |chef|
      chef.add_recipe "dhcp-dash"

      chef.json = {
        "dhcp" => {
          "option" => {
            "domain_name" => DOMAIN_NAME,
            "dns_servers" => "8.8.8.8"
          },
          "pool" => {
            "range" => "10.10.10.5 10.10.10.254",
            "mask" => "255.255.255.0",
            "network" => "10.10.10.0",
            "routers" => "10.10.10.1"
          }
        },
        "rbenv" => {
          "group_users" => "vagrant"
        },
        "dhcp-dash" => {
          "environment" => "development"
        }
      }
    end
  end
end
