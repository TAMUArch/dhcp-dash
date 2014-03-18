require 'ipaddr'

def subvalidate (netmask, ip)

  cidr = IPAddr.new(netmask).to_i.to_s(2).count("1").to_s
  subvalid = ip + "/" + cidr

  if subvalid === ip
    puts "your ip is valid based on subnet"
  else
    puts "your ip is NOT valid based on subnet"
  end
end

subvalidate(params['netmask'], params['network'])
