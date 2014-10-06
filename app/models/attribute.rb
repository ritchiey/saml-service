class Attribute < Sequel::Model
  plugin :class_table_inheritance

  one_to_one :name_format
  one_to_many :attribute_values

  many_to_one :idp_sso_descriptor

  def validate
    super
    validates_presence [:name, :created_at, :updated_at]
  end
end
