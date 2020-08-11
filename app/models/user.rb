class User < ApplicationRecord
  has_secure_password
  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  validates :email, presence: true,
                    uniqueness: true,
                    format: { with: EMAIL_REGEX, on: :create, allow_blank: true }

  has_many :links
end
