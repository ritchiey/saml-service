class EntitiesDescriptor < Sequel::Model
  def validate
    super
    validates_presence [:identifier, :name, :created_at, :updated_at]
  end
end
