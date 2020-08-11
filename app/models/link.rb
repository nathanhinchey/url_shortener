class Link < ApplicationRecord
  belongs_to :user

  validates :slug, uniqueness: true
  validates :target, presence: true,
                     format: { with: URI::DEFAULT_PARSER.regexp[:ABS_URI],
                               allow_blank: true }

  after_create :ensure_slug

  # characters I find easy to distinguish even when hand written
  NON_CONFUSING_CHARS = "abdefghnpqrty"\
                        "ABDEFGHJLNPQRTY"\
                        "234689".freeze

  # make sure every link has a unique slug
  def ensure_slug
    if slug.blank?
      update(slug: self.class.find_available_slug(id))
    end
  end

  # for collisions because of custom slugs, find an available slug
  def self.find_available_slug(integer)
    slug = integer_to_slug(integer)
    link = find_by(slug: slug)
    if link
      find_available_slug(link.id)
    else
      slug
    end
  end

  # hash an integer by converting it to base NON_CONFUSING_CHARS.length
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
