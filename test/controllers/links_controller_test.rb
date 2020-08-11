require 'test_helper'

class LinksControllerTest < ActionDispatch::IntegrationTest
  def auth_header(user)
    token = Knock::AuthToken.new(payload: { sub: users(user).id }).token

    {
      'Authorization': "Bearer #{token}"
    }
  end

  # links#index

  test 'index should reply with 401 when user does not authenticate' do
    get '/api/v1/links'
    assert_response :unauthorized
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

  # links#slug_redirect

  test 'should redirect to target from /<slug>' do
    get "/#{links(:one).slug}"
    assert_redirected_to links(:one).target
  end

  test 'should render 404 for unknown slug' do
    get "/this_slug_cannot_be_found_lol"
    assert_response :not_found
  end

  # links#create

  test 'create should return 401 if auth is missing from request' do
    post '/api/v1/links'
    assert_response :unauthorized
  end

  test 'create should accept a target with no custom slug' do
    params = { target: 'http://example.com' }
    post "/api/v1/links", params: params, headers: auth_header(:creator)
    assert_response :success
  end

  test 'create with a target and no slug should create a link record' do
    target = 'http://example.com'
    params = { target: target }
    assert_changes -> { Link.find_by(target: target) }, from: nil do
      post "/api/v1/links", params: params, headers: auth_header(:creator)
    end
  end

  test 'create should respond with the target and slug on successful creation' do
    target = "http://example.com/#{SecureRandom.alphanumeric(5)}"
    params = { target: target }
    post "/api/v1/links", params: params, headers: auth_header(:creator)
    slug = Link.find_by(target: target).slug
    assert_includes response.body, target
    assert_includes response.body, slug
  end

  test 'create should accept a custom slug' do
    target = "http://example.com/#{SecureRandom.alphanumeric(5)}"
    expected_slug = 'my_custom_slug'
    params = { target: target, slug: expected_slug }
    post "/api/v1/links", params: params, headers: auth_header(:creator)
    assert_equal expected_slug, Link.find_by(target: target).slug
  end

  test 'create should respond with 201 for successful creation' do
    target = 'http://example.com'
    params = { target: target }
    post "/api/v1/links", params: params, headers: auth_header(:creator)
    assert_response :created
  end

  test 'create should respond with 422 if slug is unavailable' do
    target = 'http://example.com'
    slug = links(:one).slug
    params = { target: target, slug: slug }
    post "/api/v1/links", params: params, headers: auth_header(:creator)
    assert_response :unprocessable_entity
  end

  # links#destroy

  test 'destroy should return 401 for unauthonticated request' do
    post '/api/v1/links'
    assert_response :unauthorized
  end

  test 'destroy should remove the link record if it belongs to current user' do
    assert_difference -> { Link.count }, -1 do
      delete "/api/v1/links/#{links(:one).slug}", headers: auth_header(:creator)
    end
  end

  test 'destroy should not remove the link record if it does not belong to current user' do
    assert_no_difference -> { Link.count } do
      delete "/api/v1/links/#{links(:one).slug}", headers: auth_header(:non_creator)
    end
  end

  test 'destroy should return 403 (forbidden) if the link does not belong to current user' do
    delete "/api/v1/links/#{links(:one).slug}", headers: auth_header(:non_creator)
    assert_response :forbidden
  end

  test 'destroy should return 404 if the link does not exist' do
    delete '/api/v1/links/not_a_link_yo', headers: auth_header(:non_creator)
    assert_response :not_found
  end
end
