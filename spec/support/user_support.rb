module ValidUserRequestHelper

  def sign_in_as_admin
    @admin || = FactoryGirl.create(:user, :admin_user)

    post_via_redirect user_session_path, 'user[email]' => @admin.email, 'user[password]' => @admin.password
  end

  def sign_in_as_user
    @user || = FactoryGirl.create(:user, :user_user)

    post_via_redirect user_session_path, 'user[email]' => @admin.email, 'user[password]' => @admin.password
  end

  def sign_in_as_spectator
    @spectator || = FactoryGirl.create(:user, :spectator_user)

    post_via_redirect user_session_path, 'user[email]' => @admin.email, 'user[password]' => @admin.password
  end
end

RSpec.configure do |config|
  config.include ValidUserRequestHelper, :type => :request
end
