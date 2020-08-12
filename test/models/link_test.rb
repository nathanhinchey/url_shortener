require 'test_helper'

class LinkTest < ActiveSupport::TestCase
  test 'should create a default slug if none is included' do
    link = Link.create(user: users(:creator), target: 'http://example.com')
    assert link.slug.present?
  end

  # test '#find_available_slug should '
end
