require 'sinatra'
require 'json'
require 'sinatra/formkeeper'
require 'omniauth'
require 'omniauth-ldap'
require 'slim'
require 'pony'
#require 'IPAddr'
require_relative 'lib/dhcpdash'
require_relative 'dash_config'

include DHCPDash

configure do
  set :public_folder, proc { File.join(root, 'static') }
  enable :sessions
  Slim::Engine.set_default_options pretty: true, sort_attrs: false
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Login'
  end

  def networks
    json_files = Dir.entries('./networks').reject { |n| !n.match(/.json/) }
    json_files.each do |file|
      file.gsub!('.json', '')
      file.gsub!('_', '.')
    end
  end
end

%w{network networks hosts}.each do |path|
  before "/#{path}/*" do
    unless session[:identity]
      session[:previous_url] = request.path
      redirect '/auth/ldap'
    end
  end

  def email (subject, body)
    mail = DHCPDash.admin_emails
    mail.each do |address|
      Pony.mail(:to => address, :subject => subject, :body => body, :via => :sendmail)
    end
  end
=begin
  def subvalidate (netmask, ip)
    cidr = IPAddr.new(netmask).to_i.to_s(2).count("1").to_s
    subvalid = ip + "/" + cidr
    subvalid === ip
  end
=end
end

get '/' do
  if session[:identity].nil?
    slim "<div class='alert-message'><b>You must authenticate to use this application.</b></div>"
  else
    group = session[:group]
    case group
    when 'spectator'
      slim :homepage, layout: :layout_spectator
    when 'user'
      slim :homepage, layout: :layout_user
    when 'admin'
      slim :homepage
    end
  end
end

post '/auth/:provider/callback' do
  membership = env['omniauth.auth'].extra.raw_info.memberOf
  case
  when membership.include?(DHCPDash.admin_group)
    session[:identity] = env['omniauth.auth'].info.name
    session[:group] = 'admin'
    redirect '/'
  when membership.include?(DHCPDash.user_group)
    session[:identity] = env['omniauth.auth'].info.name
    session[:group] = 'user'
    redirect '/'
  when membership.include?(DHCPDash.spectator_group)
    session[:identity] = env['omniauth.auth'].info.name
    session[:group] = 'spectator'
    redirect '/'
  else
    session.delete(:identity)
    session.delete(:group)
    slim "<div class='alert-message'><b>You are not authorized to access this application.</b></div>"
  end
end

get '/auth/failure?' do
  slim "<div class='alert-message'><b>Invalid credentials. Please make another login attempt.</b></div>"
end

get '/login/form' do
  redirect '/auth/ldap'
end

get '/logout' do
  session.delete(:identity)
  session.delete(:group)
  slim "<div class='alert-message'><b>Logged out</b></div>"
end

get '/network/:id' do
  @network = return_network(params['id'].gsub('_', '.'))
  group = session[:group]
  case group
  when 'spectator'
    @limited_view = true
    @restricted_view = true
    slim :network, layout: :layout_spectator
  when 'user'
    @restricted_view = true
    slim :network, layout: :layout_user
  when 'admin'
    slim :network
  end
end

post '/network/new' do
  domain_regex = /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}$/
  ip_regex = /^\b((25[0-5]|2[0-4]\d|[01]?\d{1,2})\.){3}(25[0-5]|2[0-4]\d|[01]?\d{1,2})\b$/
  netmask_regex = /^(((128|192|224|240|248|252|254)\.0\.0\.0)|(255\.(0|128|192|224|240|248|252|254)\.0\.0)|(255\.255\.(0|128|192|224|240|248|252|254)\.0)|(255\.255\.255\.(0|128|192|224|240|248|252|254)))$/
  nameserver_regex = /^(((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?),?)*+$/
  form do
    field :domain, present: true, regexp: domain_regex
    field :network, present: true, regexp: ip_regex
    field :netmask, present: true, regexp:  netmask_regex
    field :gateway, present: true, regexp: ip_regex
    field :nameservers, present: true, regexp: nameserver_regex
  end

  if form.failed?
    output = slim :network_form, layout: :layout_user
    fill_in_form(output)
=begin
  elsif !subvalidate(params['netmask'], params['network'])
    output = slim :network_form
    fill_in_form(output)
=end
  else
    net = return_network(params['network'])
    net.domain = params['domain']
    net.netmask =  params['netmask']
    net.gateway = params['gateway']
    net.nameservers = params['nameservers'].split(',')
    save_network(net)
    redirect "/network/#{params['network']}"
  end
end

post '/network/:id/edit' do
  domain_regex = /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}$/
  ip_regex = /\b((25[0-5]|2[0-4]\d|[01]?\d{1,2})\.){3}(25[0-5]|2[0-4]\d|[01]?\d{1,2})\b/
  nameserver_regex = /^(((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?),?)*+$/
  form do
    field :domain, present: true, regexp: domain_regex
    field :gateway, present: true, regexp: ip_regex
    field :nameservers, present: true, regexp: nameserver_regex
  end

  if form.failed?
    @network = return_network(params['network'])
    output = slim :edit_network, layout: :layout_user
    fill_in_form(output)
  else
    net = return_network(params['network'])
    net.domain = params['domain']
    net.netmask =  params['netmask']
    net.gateway = params['gateway']
    net.nameservers = params['nameservers'].split(',')
    save_network(net)
    redirect "/network/#{params['network']}"
  end
end

post '/network/:id/delete' do
  delete_network(params['network'].gsub('.', '_'))
  redirect '/'
end

post '/network/:id/hosts/new' do
  ip_regex = /\b((25[0-5]|2[0-4]\d|[01]?\d{1,2})\.){3}(25[0-5]|2[0-4]\d|[01]?\d{1,2})\b/
  mac_regex = /^(?:[[:xdigit:]]{2}([:]))(?:[[:xdigit:]]{2}\1){4}[[:xdigit:]]{2}$/
  form do
    field :hostname, present: true
    field :ip, present: true, regexp: ip_regex
    field :mac, present: true, regexp: mac_regex
  end
  net = return_network(params['network'])

  exists_array = [net.hostname_exists?(params['hostname']),
                  net.host_ip_exists?(params['ip']),
                  net.host_mac_exists?(params['mac'])]

  host_exists = exists_array.any?

  if form.failed? #|| !subvalidate(params['netmask'], params['network'])
    net = return_network(params['network'])
    @network = net.network
    output = slim :host_form, layout: :layout_user
    fill_in_form(output)

  elsif host_exists
    net = return_network(params['network'])
    @network = net.network
    output = slim :host_exists, layout: :layout_user
    fill_in_form(output)

  else
    net.add_host(
      params['hostname'],
      params['ip'],
      params['mac'])
    save_network(net)
    email('Added Host', params['hostname'])
    redirect "/network/#{params['network']}"
  end
end

post '/network/:id/hosts/edit' do
  ip_regex = /\b((25[0-5]|2[0-4]\d|[01]?\d{1,2})\.){3}(25[0-5]|2[0-4]\d|[01]?\d{1,2})\b/
  mac_regex = /^(?:[[:xdigit:]]{2}([:]))(?:[[:xdigit:]]{2}\1){4}[[:xdigit:]]{2}$/
  form do
    field :hostname, present: true
    field :ip, present: true, regexp: ip_regex
    field :mac, present: true, regexp: mac_regex
  end
  net = return_network(params['network'])

  unless params['ip'] == params['current_ip']
    ip_exists = net.host_ip_exists?(params['ip'])
  end

  unless params['mac'] == params['current_mac']
    mac_exists = net.host_mac_exists?(params['mac'])
  end

  exists_array =  [ip_exists, mac_exists]

  host_exists = exists_array.any?

  if form.failed? #|| !subvalidate(params['netmask'], params['network'])
    net = return_network(params['network'])
    @network = net.network
    @host = net.hosts[params['hostname']]
    @hostname = params['hostname']
    output = slim :edit_host, layout: :layout_user
    fill_in_form(output)

  elsif host_exists
    net = return_network(params['network'])
    @network = net.network
    output = slim :host_exists, layout: :layout_user
    fill_in_form(output)

  else
    net.edit_host(
      params['hostname'],
      params['ip'],
      params['mac'])
    save_network(net)
    redirect "/network/#{params['network']}"
  end
end

post '/network/:id/hosts/delete' do
  net = return_network(params['id'])
  net.delete_host(params['hostname'])
  save_network(net)
  email('Deleted Host', params['hostname'])
  redirect "/network/#{params['id']}"
end

post '/refresh' do
  group = session[:group]

  case group
  when 'user'
    run_chef
  when 'admin'
    run_chef
  end

  redirect '/'
end
