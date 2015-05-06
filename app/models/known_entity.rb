class KnownEntity < Sequel::Model
  many_to_one :entity_source
  one_to_one :entity_descriptor
  one_to_one :raw_entity_descriptor

  one_to_many :tags

  alias_method :active?, :active

  def validate
    super
    validates_presence [:entity_source, :active, :created_at, :updated_at]
  end

  def self.with_any_tag(tags)
    join_tags(tags).all
  end

  def self.with_all_tags(tags)
    join_tags(tags).having { "count(*) = #{[tags].flatten.length}" }.all
  end

  def self.join_tags(tags)
    qualify.join(:tags, known_entity_id: :id, name: tags)
      .group(:known_entity_id)
  end
end
