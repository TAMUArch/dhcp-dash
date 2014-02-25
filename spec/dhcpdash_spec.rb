require_relative '../lib/dhcpdash.rb'
include DHCPDash

describe DHCPDash do

  describe '#return_network' do
    return_network('192.168.0.1').class.should == Network
  end
end
