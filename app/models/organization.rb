class Organization < Sequel::Model
  one_to_many :entity_descriptors
  one_to_many :role_descriptors

  def validate
    super
    validates_presence [:name, :display_name, :url, :created_at, :updated_at]
  end
end
