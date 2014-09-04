class Attribute < Sequel::Model
  many_to_one :attribute_base
  one_to_many :attribute_values

  def validate
    super
    validates_presence [:attribute_base, :created_at, :updated_at]
  end
end
