class KnownEntity < Sequel::Model
  plugin :touch

  many_to_one :entity_source
  one_to_one :entity_descriptor
  one_to_one :raw_entity_descriptor

  one_to_many :tags

  plugin :association_dependencies, entity_descriptor: :destroy,
                                    raw_entity_descriptor: :destroy,
                                    tags: :destroy

  alias_method :enabled?, :enabled

  def validate
    super
    validates_presence [:entity_source, :enabled, :created_at, :updated_at]
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

  def tag_as(name)
    return if tags.any? { |t| t.name == name }
    add_tag(Tag.new(name: name))
  end

  def untag_as(name)
    tags.delete_if { |t| t.name == name }
    Tag.where(name: name, known_entity: self).destroy
  end

  def entity_id
    return entity_descriptor.entity_id.uri if entity_descriptor
    return raw_entity_descriptor.entity_id.uri if raw_entity_descriptor

    nil
  end
end
