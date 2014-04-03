require_relative '../app.rb'
require_relative 'spec_helper.rb'

=begin
describe 'helpers' do
  describe '#username' do
    it 'returns username' do

    end

  end
  describe '#networks' do
    it 'returns networks according to the json files in networks directory' do

    end

  end
  describe '#email' do
    it 'sets up email notofication' do

    end

  end
end
=end

describe 'homepage' do
#  before { get :homepage }

  it 'displays the homepage for unauthorized user' do
    visit '/'
 #   session[:identity].nil == true
    page.should have_content('You must authenticate to use this application.')
  end

  it 'displays the homepage for spectator' do
#      sign_in_as_spectator
    visit '/'
   # session[:group] = 'spectator'
    it { should render_template('homepage') }
  end
  it 'displays the homepage for user' do
#      sign_in_as_user
    visit '/'
 #   session[:group] = 'user'
    response.should render_template(:homepage, layout: :layout_user)
  end
  it 'displays the homepage for admin' do
#      sign_in_as_admin
    visit '/'
 #   session[:group] = 'admin'
    response.should render_template(:homepage)
  end
end
