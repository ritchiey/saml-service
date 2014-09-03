class AttributeValue < Sequel::Model
  def validate
    super
    validates_presence [:value, :approved, :created_at, :updated_at]
  end
end
