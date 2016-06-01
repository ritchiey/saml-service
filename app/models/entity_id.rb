# frozen_string_literal: true
require 'digest/sha1'

class EntityId < SamlURI
  VALID_URI_REGEX = /\A#{URI.regexp}\z/
  include Parents

  many_to_one :entity_descriptor
  many_to_one :raw_entity_descriptor

  def validate
    super
    validates_presence :sha1
    validates_max_length 1024, :uri
    validates_format(VALID_URI_REGEX, :uri, message: 'is not a valid uri')

    return if new?

    single_parent [:entity_descriptor, :raw_entity_descriptor]
  end

  def before_validation
    super
    self.sha1 = Digest::SHA1.hexdigest uri if uri
  end

  def parent
    entity_descriptor || raw_entity_descriptor
  end
end
