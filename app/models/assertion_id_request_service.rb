class AssertionIdRequestService < Endpoint
  many_to_one :idp_sso_descriptor
  many_to_one :attribute_authority_descriptor

  def validate
    super
    return if new?

    owners = [idp_sso_descriptor, attribute_authority_descriptor].compact

    return if owners.one?
    errors.add(:ownership,
               'must be related to idp_sso_descriptor or
               attribute_authority_descriptor') && return if owners.none?

    errors.add(:ownership, 'cannot be owned by both idp_sso_descriptor
                            and attribute_authority_descriptor')
  end
end
