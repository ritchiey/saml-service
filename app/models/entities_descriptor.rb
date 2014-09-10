class EntitiesDescriptor < Sequel::Model
  one_to_many :entity_descriptors

  def validate
    super
    validates_presence [:identifier, :name, :created_at, :updated_at]
  end
end
