
require 'rubygems'
require 'sinatra'
require 'json'

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
