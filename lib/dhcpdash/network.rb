module DHCPDash
  class Network
    attr_accessor :id, :domain, :network, :netmask, :gateway, :nameservers, :hosts

    def initialize(network, options = {})
      @domain = options['domain']
      @network = network
      @netmask = options['netmask']
      @gateway = options['gateway']
      @nameservers = options['nameservers']
      @hosts = options['hosts']
      if @hosts.nil?
        @hosts = {}
      end
    end

    def add_host(hostname, ip, mac)
      @hosts[hostname] = {
        "ip" => ip,
        "mac" => mac
      }
    end

    def exists?
      File.exists?(@network.gsub('.', '_') + ".json")
    end

    def id
      @network.gsub('.', '_')
    end

    def to_hash
      {
        "id" => id,
        "domain" => @domain,
        "network" => @network,
        "netmask" => @netmask,
        "gateway" => @gateway,
        "nameservers" => @nameservers,
        "hosts" => @hosts
      }
    end
  end
end
