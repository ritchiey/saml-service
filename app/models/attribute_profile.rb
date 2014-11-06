class AttributeProfile < SamlURI
  include DualOwners

  many_to_one :idp_sso_descriptor
  many_to_one :attribute_authority_descriptor

  def validate
    super
    return if new?

    owners = [idp_sso_descriptor, attribute_authority_descriptor].compact
    valid_owner owners
  end
end
