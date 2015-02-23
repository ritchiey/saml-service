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
  end
end
