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
end

before '/network/*' do
  if !session[:identity] then
    session[:previous_url] = request.path
    @error = 'Sorry guacamole, you need to be logged in to visit ' + request.path
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

get "/network/:id" do
  @network = return_network(params["id"].gsub("_", "."))
  erb :network 
end

get '/networks/new' do
  erb :networks_form
end

get '/hosts/new' do
  erb :hosts_form
end

post '/networks/new' do
  domain_regex = %r{^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}$}
  ip_regex = %r{\b((25[0-5]|2[0-4]\d|[01]?\d{1,2})\.){3}(25[0-5]|2[0-4]\d|[01]?\d{1,2})\b}
  nameserver_regex = %r{^\S*\b((25[0-5]|2[0-4]\d|[01]?\d{1,2})\.){3}(25[0-5]|2[0-4]\d|[01]?\d{1,2})\b|\b((25[0-5]|2[0-4]\d|[01]?\d{1,2})\.){3}(25[0-5]|2[0-4]\d|[01]?\d{1,2})\b[,]\b((25[0-5]|2[0-4]\d|[01]?\d{1,2})\.){3}(25[0-5]|2[0-4]\d|[01]?\d{1,2})\b$}
  form do
    field :domain, :present => true, :regexp => domain_regex
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
    net.domain = params['domain']
    net.netmask =  params['netmask']
    net.gateway = params['gateway']
    net.nameservers = params['nameservers'].split(",")
    save_network(net)
    redirect '/'
  end
end

post '/hosts/new' do
  form do
    field :hostname, :present => true
    field :ip, :present => true, :regexp => %r{\b((25[0-5]|2[0-4]\d|[01]?\d{1,2})\.){3}(25[0-5]|2[0-4]\d|[01]?\d{1,2})\b}
    field :mac, :present => true
  end
  net = return_network(params['network'])

  exists_array = Array.new
  exists_array = [net.hostname_exists?(params['hostname']),
                  net.host_ip_exists?(params['ip']),
                  net.host_mac_exists?(params['mac'])]

  host_exists = exists_array.any?

  if form.failed?
    output = erb :hosts_form
    fill_in_form(output)

  elsif host_exists
    output = erb :host_exists
    fill_in_form(output)

  else
    net.add_host(params['hostname'],
             params['ip'],
             params['mac'])
    save_network(net)
    redirect "/network/#{params['network']}"
  end
end

get '/network/:id/edit' do
  @network = return_network(params['id'])
  erb :edit_network
end

get '/network/:id/hosts/:hostname/edit' do
  net = return_network(params['id'])
  @network = net.network
  @host = net.hosts[params['hostname']]
  @hostname = params['hostname']
  erb :edit_host
end

get '/network/:id/hosts/:hostname/delete' do
  net = return_network(params['id'])
  @network = net.network
  @host = net.hosts
  @hostname = params['hostname']
  erb :delete_host
end

post '/network/:id/edit' do
  domain_regex = %r{^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}$}
  ip_regex = %r{\b((25[0-5]|2[0-4]\d|[01]?\d{1,2})\.){3}(25[0-5]|2[0-4]\d|[01]?\d{1,2})\b}
  nameserver_regex = %r{^\S*\b((25[0-5]|2[0-4]\d|[01]?\d{1,2})\.){3}(25[0-5]|2[0-4]\d|[01]?\d{1,2})\b|\b((25[0-5]|2[0-4]\d|[01]?\d{1,2})\.){3}(25[0-5]|2[0-4]\d|[01]?\d{1,2})\b[,]\b((25[0-5]|2[0-4]\d|[01]?\d{1,2})\.){3}(25[0-5]|2[0-4]\d|[01]?\d{1,2})\b$}
  form do
    field :domain, :present => true, :regexp => domain_regex
    field :gateway, :present => true, :regexp => ip_regex
    field :nameservers, :present => true, :regexp => nameserver_regex
  end

  puts params['network']

  if form.failed?
    output = erb :edit_network
    fill_in_form(output)
  else
    net = return_network(params['network'])
    net.domain = params['domain']
    net.netmask =  params['netmask']
    net.gateway = params['gateway']
    net.nameservers = params['nameservers'].split(",")
    save_network(net)
    redirect "/network/#{params['network']}"
  end
end

post '/network/:id/hosts/:hostname/edit' do
  form do
    field :hostname, :present => true
    field :ip, :present => true, :regexp => %r{\b((25[0-5]|2[0-4]\d|[01]?\d{1,2})\.){3}(25[0-5]|2[0-4]\d|[01]?\d{1,2})\b}
    field :mac, :present => true
  end
  net = return_network(params['network'])

  unless params['ip'] == params['current_ip']
    ip_exists = net.host_ip_exists?(params['ip'])
  end

  unless params['mac'] == params['current_mac']
    mac_exists = net.host_mac_exists?(params['mac'])
  end

  exists_array =  [ip_exists,
                  mac_exists]

  host_exists = exists_array.any?

  if form.failed?
    output = erb :hosts_form
    fill_in_form(output)

  elsif host_exists
    output = erb :host_exists
    fill_in_form(output)

  else
    net.edit_host(params['hostname'],
             params['ip'],
             params['mac'])
    save_network(net)
    redirect "/network/#{params['network']}"
  end
end

post '/network/:id/hosts/:hostname/delete' do
  net = return_network(params['id'])
  net.delete_host(params['hostname'])
  save_network(net)
  redirect "/network/#{params['network']}"
end

