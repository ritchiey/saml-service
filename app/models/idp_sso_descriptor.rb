class IdpSsoDescriptor < SsoDescriptor
  one_to_many :single_sign_on_services
  one_to_many :name_id_mapping_services
  one_to_many :assertion_id_request_services
  one_to_many :attribute_profiles, class: :SamlUri, key: :role_descriptor_id
  one_to_many :attributes

  def validate
    super
    validates_presence :want_authn_requests_signed

    return if new?
    validates_presence :single_sign_on_services, allow_missing: false
  end
end
