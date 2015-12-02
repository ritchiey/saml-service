class KnownEntity < Sequel::Model
  plugin :touch

  many_to_one :entity_source
  one_to_one :entity_descriptor
  one_to_one :raw_entity_descriptor

  one_to_many :tags

  plugin :association_dependencies, entity_descriptor: :destroy,
                                    raw_entity_descriptor: :destroy,
                                    tags: :destroy

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

  def entity_id
    return entity_descriptor.entity_id.uri if entity_descriptor
    return raw_entity_descriptor.entity_id.uri if raw_entity_descriptor

    nil
  end
end
