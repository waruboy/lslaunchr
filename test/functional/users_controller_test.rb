require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test 'get new is successful'  do
    get :new
    assert_response :success
  end

  test 'post an existing email will not create a user' do
    invalid_params = { email: users(:one).email }
    assert_no_difference 'User.count' do
      post :create, user: invalid_params
    end
    assert_redirected_to '/refer-a-friend'
  end

  test 'post is successful with valid attributes' do
    user_params = {email: "new_user@example.com"}
    assert_difference 'User.count' do
      post :create, user: user_params
    end
    assert_redirected_to '/refer-a-friend'
  end

  test 'post a blank email will not create a user' do
    invalid_params = { email: '' }
    assert_no_difference 'User.count' do
      post :create, user: invalid_params
    end
    assert_response :redirect
  end
end
