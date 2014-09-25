class SamlUri < Sequel::Model
  many_to_one :role_descriptor

  TYPE = { attribute_name_format: 0, attribute_profile: 1,
           name_identifier_format: 2, protocol_binding: 3,
           protocol_support: 4 }

  def type
    TYPE.key(super)
  end

  def type=(t)
    super TYPE[t]
  end

  def validate
    super
    validates_presence [:uri, :type, :created_at, :updated_at]
    validates_includes TYPE.keys, :type
  end
end
