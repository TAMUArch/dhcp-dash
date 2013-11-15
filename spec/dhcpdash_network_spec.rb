require_relative '../lib/dhcpdash/network.rb'

describe DHCPDash::Network do
  before :each do
    @network = DHCPDash::Network.new('123.0.0.1')
    @network.add_host('test1', '192.168.0.1', '00:50:56:b2:64:c0')
  end

  describe "#hosts" do
    it "should return an empty hash by default" do
      @network.hosts.class.should == Hash
    end
  end

  describe "#hostname_exists?" do
    it "should return true if the hostname exists" do
      @network.hostname_exists?('test1').should == true
    end
  end

  describe "#host_ip_exists?" do
    it "should return true if the ip exists" do
      @network.host_ip_exists?('192.168.0.1').should == true
    end
  end

  describe "#host_mac_exists?" do
    it "should return true if the mac exists" do
      @network.host_mac_exists?('00:50:56:b2:64:c0').should == true
    end
  end

  describe "#add_host" do
    it "should add a host" do
      @network.add_host('test', '192.168.1.0', '00:50:56:b2:64:aa')
      @network.hostname_exists?('test').should == true
    end
  end

  describe "#edit_host" do
    it "should edit the host" do
      @network.edit_host('test1', '192.168.1.0', '00:50:56:b2:64:c0')
      @network.hosts['test1']['ip'].should == '192.168.1.0'
    end
  end

  describe "#delete_host" do
    it "should delete the host" do
      @network.delete_host('test1')
      @network.hostname_exists?('test1').should == false
    end
  end

  describe "#id" do
    it "should return the id" do
      @network.id.should == '123_0_0_1'
    end
  end

  describe "#to_hash" do
    it "should create a hash of the values" do
      @network.to_hash.class.should == Hash
    end
  end
end
