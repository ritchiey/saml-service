# frozen_string_literal: true

class DerivedTag < Sequel::Model
  VALID_TAG_CHARS = /[a-zA-Z0-9_-]+/.freeze
  VALID_TAG = Tag::URL_SAFE_BASE_64_ALPHABET
  VALID_TAG_LIST = /\A((#{VALID_TAG_CHARS},)*#{VALID_TAG_CHARS})?\z/.freeze

  alias enabled? enabled

  def validate
    super
    validates_presence %i[enabled tag_name when_tags unless_tags rank
                          created_at updated_at]
    validates_format VALID_TAG, :tag_name
    validates_format VALID_TAG_LIST, %i[when_tags unless_tags]
  end

  def matches?(tags)
    cond_when = when_tags.split(',')
    cond_unless = unless_tags.split(',')
    (tags & cond_when == cond_when) && (tags & cond_unless).empty?
  end
end
