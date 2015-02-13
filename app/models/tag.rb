class Tag < Sequel::Model
  include Parents
  plugin :validation_helpers
  many_to_one :entity_descriptor
  many_to_one :role_descriptor

  def validate
    super
    validates_unique([:name, :entity_descriptor])
    validates_unique([:name, :role_descriptor])
    validates_presence [:name, :created_at, :updated_at]
    single_parent [:entity_descriptor, :role_descriptor]
  end

  def self.entity_descriptors(name)
    Tag.where(name: name).exclude(entity_descriptor_id: nil).all
  end

  def self.role_descriptors(name)
    Tag.where(name: name).exclude(role_descriptor_id: nil).all
  end
end
