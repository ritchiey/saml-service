class EntityDescriptor < Sequel::Model
  many_to_one :entities_descriptor
  many_to_one :organization
  one_to_many :additional_metadata_locations
  one_to_many :contact_people

  def validate
    super
    validates_presence [:entities_descriptor, :entity_id,
                        :created_at, :updated_at]
  end
end
