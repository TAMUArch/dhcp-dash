
require 'rubygems'
require 'sinatra'
require 'json'
require 'sinatra/formkeeper'
require_relative 'lib/dhcpdash'
include DHCPDash

configure do
  set :public_folder, Proc.new { File.join(root, "static") }
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Login'
  end

  def networks
    json_files = Dir.entries('./networks').reject {|n| !n.match(/.json/)}
    json_files.each do |file|
      file.gsub!('.json', '')
      file.gsub!('_', '.')
    end
  end

  def network(net="/Users/vblessing/dhcp-dash/networks/192_168_1_0.json")
    JSON.parse(IO.read(net))
  end
end

before '/networks/*' do
  if !session[:identity] then
    session[:previous_url] = request.path
    @error = 'Sorry guacamole, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

before '/networksmgr/*' do
  if !session[:identity] then
    session[:previous_url] = request.path
    @error = 'Sorry quacamole, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb 'You must authenticate to use this application.'
end

get '/login/form' do 
  erb :login_form
end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from 
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get "/networks/:id" do
  erb :network 
end

get '/networksmgr/networks_form' do
  erb :networks_form
end

get '/networksmgr/hosts_form' do
  erb :hosts_form
end

post '/networksmgr/networks_form' do
  ip_regex = %r{\b((25[0-5]|2[0-4]\d|[01]?\d{1,2})\.){3}(25[0-5]|2[0-4]\d|[01]?\d{1,2})\b}
  nameserver_regex = %r{^\S*$\b((25[0-5]|2[0-4]\d|[01]?\d{1,2})\.){3}(25[0-5]|2[0-4]\d|[01]?\d{1,2})\b|\b((25[0-5]|2[0-4]\d|[01]?\d{1,2})\.){3}(25[0-5]|2[0-4]\d|[01]?\d{1,2})\b[,]\b((25[0-5]|2[0-4]\d|[01]?\d{1,2})\.){3}(25[0-5]|2[0-4]\d|[01]?\d{1,2})\b}
  form do
    field :domain, :present => true
    field :network, :present => true, :regexp => ip_regex
    field :netmask, :present => true, :regexp => ip_regex
    field :gateway, :present => true, :regexp => ip_regex
    field :nameservers, :present => true, :regexp => nameserver_regex
  end

  if form.failed?
    output = erb :networks_form
    fill_in_form(output)
  else
    net = return_network(params['network'])

    net.domain = params["domain"]
    net.netmask =  params["netmask"]
    net.gateway = params["gateway"]
    net.nameservers = params["nameservers"].split(",")

    save_network(net)

    redirect '/'
  end
end

post '/networksmgr/hosts_form' do
  form do
    field :hostname, :present => true
    field :ip, :present => true, :regexp => %r{\b((25[0-5]|2[0-4]\d|[01]?\d{1,2})\.){3}(25[0-5]|2[0-4]\d|[01]?\d{1,2})\b}
    field :mac, :present => true
  end

  if form.failed?
    output = erb :hosts_form
    fill_in_form(output)
  else
    net = return_network(params["net"])
    puts net.domain
    net.add_host(params["hostname"],
             params["ip"],
             params["mac"])
    save_network(net)
    redirect '/'
  end

end
