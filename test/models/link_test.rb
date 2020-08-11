require 'test_helper'

class LinkTest < ActiveSupport::TestCase
  test 'should create a default slug if none is included' do
    link = Link.create(user: users(:creator), target: 'http://example.com')
    assert link.slug.present?
  end

  test 'Link.find_available_slug should find a non-colliding slug' do
    id = 999
    custom_slug = Link.find_available_slug(id)
    link = Link.create!(user: users(:creator), target: 'http://example.com', slug: custom_slug)
    assert_not_equal link.slug, Link.find_available_slug(id)
  end

  # test '#find_available_slug should '
end
