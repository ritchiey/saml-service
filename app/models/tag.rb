class Tag < Sequel::Model
  include Parents
  plugin :validation_helpers
  many_to_one :known_entity
  many_to_one :role_descriptor

  def validate
    super
    validates_unique([:name, :known_entity])
    validates_unique([:name, :role_descriptor])
    validates_presence [:name, :created_at, :updated_at]
    single_parent [:known_entity, :role_descriptor]
  end
end
