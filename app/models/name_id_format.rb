class NameIdFormat < SamlURI
  include DualOwners

  many_to_one :sso_descriptor
  many_to_one :attribute_authority_descriptor

  def validate
    super
    return if new?

    valid_owner [:sso_descriptor, :attribute_authority_descriptor]
  end
end
