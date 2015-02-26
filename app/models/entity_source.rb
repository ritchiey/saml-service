class EntitySource < Sequel::Model
  one_to_many :known_entities

  def entity_descriptors
    known_entities.map(&:entity_descriptor)
  end

  def validate
    super
    validates_presence [:rank, :active, :created_at, :updated_at]
    validates_integer :rank
    validates_unique :rank
    validate_url
  end

  def validate_url
    return if url.nil?

    validates_format URI.regexp(%w(http https)), :url
    URI.parse(url)
  rescue URI::InvalidURIError
    errors.add(:url, 'could not be parsed as a valid URI')
  end
end
