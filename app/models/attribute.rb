class Attribute < Sequel::Model
  include DualOwners

  plugin :class_table_inheritance

  one_to_one :name_format
  one_to_many :attribute_values

  many_to_one :idp_sso_descriptor
  many_to_one :attribute_authority_descriptor

  def validate
    super
    validates_presence [:name, :created_at, :updated_at]
    return if new?

    valid_owner [:idp_sso_descriptor, :attribute_authority_descriptor]
  end
end
