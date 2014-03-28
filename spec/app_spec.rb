require_relative '../app.rb'
require_relative 'spec_helper.rb'

describe 'app' do
  describe 'homepage' do
    it "displays the homepage for unauthorized user" do
      visit '/'
   #   session[:identity].nil == true
      page.should have_content('You must authenticate to use this application.')
    end
=begin
    it "displays the homepage for spectator" do
      visit '/'
      session[:group] = 'spectator'
      expect(response).to render_template(:homepage, layout: :layout_spectator)
    end
    it "displays the homepage for user" do
      visit '/'
      session[:group] = 'user'
      expect(response).to render_template(:homepage, layout: :layout_user)
    end
    it "displays the homepage for admin" do
      visit '/'
      session[:group] = 'admin'
      expect(response).to render_template(:homepage)
    end
=end
  end
end
