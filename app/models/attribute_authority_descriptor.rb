class AttributeAuthorityDescriptor < RoleDescriptor
  one_to_many :attribute_services
  one_to_many :assertion_id_request_services
  one_to_many :name_id_formats
  one_to_many :attribute_profiles
  one_to_many :attributes

  def validate
    super
    validates_presence :attribute_services, allow_missing: new?
  end
end
