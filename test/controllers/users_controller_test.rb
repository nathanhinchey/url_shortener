require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def valid_password
    SecureRandom.base64
  end

  test 'create should accept email and password' do
    params = { email: 'new_user@example.com', password: valid_password }
    post '/api/v1/users', params: params
    assert_response :success
  end

  test 'create should make a new user record' do
    params = { email: 'new_user@example.com', password: valid_password }
    assert_difference -> { User.count }, 1 do
      post '/api/v1/users', params: params
    end
  end

  test 'create should return the email address of new user record' do
    email = 'new_user@example.com'
    params = { email: email, password: valid_password }
    post '/api/v1/users', params: params
    body = JSON.parse(response.body)
    expected_body = { "email" => email }
    assert_equal expected_body, body
  end

  test 'create should return 422 if no email is present' do
    params = { password: valid_password }
    post '/api/v1/users', params: params
    assert_response :unprocessable_entity
  end

  test 'create should return error message if no email is present' do
    params = { password: valid_password }
    post '/api/v1/users', params: params
    actual_email_errors = JSON.parse(response.body)["errors"]["email"]
    expected_email_errors = ["can't be blank"]
    assert_equal expected_email_errors, actual_email_errors
  end

  test 'create should return error message if no email is invalid' do
    params = { email: 'not_an_email_address', password: valid_password }
    post '/api/v1/users', params: params
    body = JSON.parse(response.body)
    assert_equal body["errors"]["email"], ["is invalid"]
  end

  test 'create should return error message if email is not unique' do
    email = users(:creator).email
    params = { email: email, password: valid_password }
    post '/api/v1/users', params: params
    actual_email_errors = JSON.parse(response.body)["errors"]["email"]
    expected_email_errors = ["has already been taken"]
    assert_equal expected_email_errors, actual_email_errors
  end

  test 'create should return error message if no password is given' do
    params = { email: 'new_user@example.com' }
    post '/api/v1/users', params: params
    actual_password_errors = JSON.parse(response.body)["errors"]["password"]
    expected_password_errors = ["can't be blank"]
    assert_equal expected_password_errors, actual_password_errors
  end
end
