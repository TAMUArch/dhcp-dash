module DHCPDash
  def add_host(hostname, ip, mac, network)
    net = return_network(network_id(network))
    net['hosts'][hostname] = {
      "ip" => ip,
      "mac" => mac
    }

    save_network(network_id(network), net)
  end

  def network_exists?(network)
    File.exists?(network.gsub('.', '_') + ".json")
  end

  def add_network(domain, network, netmask, gateway, nameservers = [])
    output = {
      "id" => network_id(network),
      "domain" => domain, 
      "network" => network,
      "netmask" => netmask,
      "gateway" => gateway,
      "nameservers" => nameservers.split(",")}
    save_network(network_id(network), output) 
  end

  def network_id(network)
    network.gsub('.', '_')
  end

  def save_network(id, network_hash)
    File.open("./networks/#{id}.json", "w") do |f|
      f.puts(JSON.pretty_generate(network_hash))
    end
  end

  def return_network(id)
    JSON.parse(IO.read("./networks/#{id}.json"))
  end
end
