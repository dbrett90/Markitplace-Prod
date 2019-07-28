require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  #Instantiate an ActionMailer for the rest of the tests to use
  #Have to clear it for other integration tests
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    assert_template 'users/new'
  end

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    #Code below verifies that exactly one message was sent
    #deliveries is a global array
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    #Try to log in before Activation
    log_in_as(user)
    assert_not is_logged_in?
    #Invalid Acrtivation Token
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    #Valid Token, Wrong Email
    get edit_account_activation_path(user.activation_token, email: "Wrong")
    assert_not is_logged_in?
    #Finally log in with a valid actvation token
    get edit_account_activation_path(user.activation_token, email:user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    # assert_not flash.empty?
    assert is_logged_in?
  end
end
