require 'spec_helper'

feature 'User Management', %q{
  As the site owner
  I want to provide user management
  so that I can protect functions and grant access based on roles
} do

  background do
    @admin = create(:user, :admin)
    @user = create(:user, :app_user)
    @spectator = create(:user, :spectator)
  end
end
