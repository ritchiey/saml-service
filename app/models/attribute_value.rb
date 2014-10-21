class AttributeValue < Sequel::Model
  many_to_one :attribute

  def validate
    super
    validates_presence [:value, :created_at, :updated_at]
    validates_presence :attribute
  end
end
