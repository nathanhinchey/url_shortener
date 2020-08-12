class Link < ApplicationRecord
  belongs_to :user

  # 1 to 64 unreserved URL safe characters (see RFC 3986)
  # NOTE: this could be a lot more permissive if we wanted
  SLUG_PATTERN = /\A[\w~\-\.]{1,64}\z/.freeze

  # characters I find easy to distinguish even when hand written
  NON_CONFUSING_CHARS = "abdefghnpqrty"\
                        "ABDEFGHJLNPQRTY"\
                        "234689".freeze

  validates :slug, uniqueness: true, format: { with: SLUG_PATTERN }
  validates :target, presence: true,
                     format: { with: URI::DEFAULT_PARSER.regexp[:ABS_URI],
                               allow_blank: true }

  before_validation :ensure_slug

  # slugs that are not allowed
  # TODO: add things like racial slurs and think about other links to forbid
  RESERVED_SLUGS = %w[
    help users admin api links
  ].freeze

  # make sure every link has a unique slug
  def ensure_slug
    return if slug.present?

    # slug_number is a decimal representation of the auto-generated slugs
    self.slug_number = self.class.next_slug_number
    self.slug = self.class.integer_to_slug(self.slug_number)
  end

  # find the next unused slug number (the decimal representation of a slug)
  def self.next_slug_number
    # find the highest slug_number we've set
    last_slug_number = order("slug_number").last.slug_number
    new_slug_number = (last_slug_number || 0) + 1
    # find slug_number that generates a valid slug
    new_slug = integer_to_slug(new_slug_number)
    until valid_slug?(new_slug)
      new_slug_number += 1
      new_slug = integer_to_slug(new_slug_number)
    end
    new_slug_number
  end

  # see if id can be converted to a valid slug
  def self.valid_slug?(slug)
    slug && !RESERVED_SLUGS.include?(slug) && !Link.find_by(slug: slug)
  end

  # convert integer to base NON_CONFUSING_CHARS.length
  def self.integer_to_slug(integer)
    base = NON_CONFUSING_CHARS.length
    chars = []
    while integer > 0
      chars.unshift(integer % base)
      integer = integer / base
    end
    chars.join
  end
end
