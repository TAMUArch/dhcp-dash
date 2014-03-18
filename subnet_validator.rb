require 'ipaddr'

def sub_validate (subnet, ip)

  cidr = IPAddr.new(params['netmask']).to_i.to_s(2).count("1").to_s
  subvalid = params['network'] + "/" + cidr

  if subvalid === params['network']
    puts "your ip is valid based on subnet"
  else
    puts "your ip is NOT valid based on subnet"
  end
end
