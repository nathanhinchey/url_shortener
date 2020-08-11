require 'test_helper'

class LinksControllerTest < ActionDispatch::IntegrationTest
  def auth_header(user)
    token = Knock::AuthToken.new(payload: { sub: users(user).id }).token

    {
      'Authorization': "Bearer #{token}"
    }
  end

  test 'index should return all links current user has created' do
    get "/v1/links", headers: auth_header(:creator)
    body = JSON.parse(response.body)
    assert users(:creator).links.all? do |link|
      body.include?({ "target" => link.target, "slug" => link.slug })
    end
  end

  test 'index should return empty list if current user has created no links' do
    get "/v1/links", headers: auth_header(:non_creator)
    body = JSON.parse(response.body)
    assert_equal [], body
  end
end
