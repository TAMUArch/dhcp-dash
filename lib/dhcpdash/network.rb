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
      unless hostname_exists?(hostname)
        @hosts[hostname] = {
          'ip' => ip,
          'mac' => mac
        }
      end
    end

    def delete_host(hostname)
      @hosts.delete(hostname)
    end

    def edit_host(hostname, ip, mac)
      @hosts[hostname] = {
        'ip' => ip,
        'mac' => mac
      }
    end

    def id
      @network.gsub('.', '_')
    end

    def to_hash
      {
        'id' => id,
        'domain' => @domain,
        'network' => @network,
        'netmask' => @netmask,
        'gateway' => @gateway,
        'nameservers' => @nameservers,
        'hosts' => @hosts
      }
    end

    def hostname_exists?(hostname)
      @hosts.key?(hostname)
    end

    def host_ip_exists?(ip)
      @hosts.each_value do |vals|
        if vals['ip'] == ip
          return true
        end
      end
      false
    end

    def host_mac_exists?(mac)
      @hosts.each_value do |vals|
        if vals['mac'] == mac
          return true
        end
      end
      false
    end
  end
end
