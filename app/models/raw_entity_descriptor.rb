class RawEntityDescriptor < Sequel::Model
  many_to_one :known_entity

  def validate
    super
    validates_presence [:known_entity, :xml, :created_at, :updated_at]
    validates_unique :known_entity
    # Any more than 65535, the column type needs to be upgraded.
    validates_max_length 65_535, :xml
  end
end
