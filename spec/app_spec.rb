require_relative '../app.rb'
require_relative 'spec_helper.rb'

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


  end
end
describe 'app' do
  describe 'homepage' do
    it 'displays the homepage for unauthorized user' do
      visit '/'
   #   session[:identity].nil == true
      page.should have_content('You must authenticate to use this application.')
    end
    it 'displays the homepage for spectator' do
      visit '/'
     # session[:group] = 'spectator'
      page.should render_template(:homepage, layout: :layout_spectator)
    end
    it 'displays the homepage for user' do
      visit '/'
   #   session[:group] = 'user'
      page.should render_template(:homepage, layout: :layout_user)
    end
    it 'displays the homepage for admin' do
      visit '/'
   #   session[:group] = 'admin'
      page.should render_template(:homepage)
    end
  end
end
