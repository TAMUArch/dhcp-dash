module DHCPDash
  class Host
    attr_accessor :hostname, :ip, :mac

    def initialize(hostname, ip, mac)
      @hostname = hostname
      @ip = ip
      @mac = mac
    end

    def to_hash
      {
        "hostname" => @hostname,
        "ip" => @ip,
        "mac" => @mac
      }
    end
  end
end
