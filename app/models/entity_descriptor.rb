class EntityDescriptor < Sequel::Model
  many_to_one :entities_descriptor
  many_to_one :organization

  one_to_many :additional_metadata_locations
  one_to_many :contact_people
  one_to_many :role_descriptors

  one_to_one :entity_id

  def validate
    super
    validates_presence [:entities_descriptor, :created_at, :updated_at]
    validates_presence :entity_id, allow_missing: new?
  end
end
