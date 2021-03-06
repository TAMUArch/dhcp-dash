require_relative 'dhcpdash/network'
require_relative 'dhcpdash/host'

module DHCPDash
  extend self

  def parameter(*names)
    names.each do |name|
      attr_accessor name

      define_method name do |*values|
        value = values.first
        value ? send("#{name}=", value) : instance_variable_get("@#{name}")
      end
    end
  end

  def config(&block)
    instance_eval &block
  end

  def network_exists?(id)
    File.exists?("./networks/#{id}.json")
  end

  def save_network(network)
    File.open("./networks/#{network.id}.json", 'w') do |f|
      f.puts(JSON.pretty_generate(network.to_hash))
    end
  end

  def return_network(network)
    net = Network.new(network)
    if network_exists?(net.id)
      n = JSON.parse(IO.read("./networks/#{net.id}.json"))
      net.domain = n['domain']
      net.netmask = n['netmask']
      net.gateway = n['gateway']
      net.nameservers = n['nameservers']
      net.hosts = n['hosts']
    end
    net
  end

  def delete_network(id)
    File.delete("./networks/#{id}.json")
  end

  def run_chef
    puts "restarting dhcp server"
    system('chef-client')
  end

end
