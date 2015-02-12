class Tag < Sequel::Model
  include Parents

  many_to_one :entity_descriptor
  many_to_one :role_descriptor

  def validate
    super
    validates_presence [:name, :created_at, :updated_at]
    single_parent [:entity_descriptor, :role_descriptor]
  end
end
