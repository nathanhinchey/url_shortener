require 'test_helper'

class LinksControllerTest < ActionDispatch::IntegrationTest
  def auth_header(user)
    token = Knock::AuthToken.new(payload: { sub: users(user).id }).token

    {
      'Authorization': "Bearer #{token}"
    }
  end

  test 'index should return all links current user has created' do
    get "/api/v1/links", headers: auth_header(:creator)
    body = JSON.parse(response.body)
    assert users(:creator).links.all? do |link|
      body.include?({ "target" => link.target, "slug" => link.slug })
    end
  end

  test 'index should return empty list if current user has created no links' do
    get "/api/v1/links", headers: auth_header(:non_creator)
    body = JSON.parse(response.body)
    assert_equal [], body
  end

  test 'should redirect to target from /<slug>' do
    get "/#{links(:one).slug}"
    assert_redirected_to links(:one).target
  end

  test 'should render 404 for unknown slug' do
    get "/this_slug_cannot_be_found_lol"
    assert_response :not_found
  end
end
