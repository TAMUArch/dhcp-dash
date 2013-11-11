require_relative 'dhcpdash/network'

module DHCPDash
  def network_exists?(id)
    File.exists?("./networks/#{id}.json")
  end

  def save_network(network)
    File.open("./networks/#{network.id}.json", "w") do |f|
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
end