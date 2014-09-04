class AttributeValue < Sequel::Model
  many_to_one :attribute

  def validate
    super
    validates_presence [:attribute, :value, :approved, :created_at, :updated_at]
  end
end
