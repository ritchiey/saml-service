class Tag < Sequel::Model
  include Parents
  plugin :validation_helpers
  many_to_one :entity_descriptor
  many_to_one :entities_descriptor
  many_to_one :role_descriptor

  def validate
    super
    validates_unique([:name, :entity_descriptor])
    validates_unique([:name, :role_descriptor])
    validates_unique([:name, :entities_descriptor])
    validates_presence [:name, :created_at, :updated_at]
    single_parent [:entity_descriptor, :role_descriptor, :entities_descriptor]
  end
end
