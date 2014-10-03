class RoleDescriptor < Sequel::Model
  plugin :class_table_inheritance

  many_to_one :entity_descriptor
  many_to_one :organization

  one_to_many :protocol_supports
  one_to_many :key_descriptors
  one_to_many :contact_people

  def validate
    super
    validates_presence [:error_url, :active, :created_at, :updated_at]
  end
end
