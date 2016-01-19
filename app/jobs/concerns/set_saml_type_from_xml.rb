module SetSAMLTypeFromXML
  ENTITY_DESCRIPTOR_XPATH =
    '//*[local-name() = "EntityDescriptor" and ' \
    'namespace-uri() = "urn:oasis:names:tc:SAML:2.0:metadata"]'
    .freeze
  private_constant :ENTITY_DESCRIPTOR_XPATH

  IDP_SSO_DESCRIPTOR_XPATH =
    '//*[local-name() = "IDPSSODescriptor" and ' \
    'namespace-uri() = "urn:oasis:names:tc:SAML:2.0:metadata"]'
    .freeze
  private_constant :IDP_SSO_DESCRIPTOR_XPATH

  ATTRIBUTE_AUTHORITY_DESCRIPTOR_XPATH =
    '//*[local-name() = "AttributeAuthorityDescriptor" and ' \
    'namespace-uri() = "urn:oasis:names:tc:SAML:2.0:metadata"]'
    .freeze
  private_constant :ATTRIBUTE_AUTHORITY_DESCRIPTOR_XPATH

  SP_SSO_DESCRIPTOR_XPATH =
    '//*[local-name() = "SPSSODescriptor" and ' \
    'namespace-uri() = "urn:oasis:names:tc:SAML:2.0:metadata"]'
    .freeze
  private_constant :SP_SSO_DESCRIPTOR_XPATH

  def set_saml_type(red, ed_node)
    set_as_idp(red, ed_node)
    set_as_aa(red, ed_node)
    set_as_sp(red, ed_node)
  end

  def set_as_idp(red, ed_node)
    return unless ed_node.xpath(IDP_SSO_DESCRIPTOR_XPATH).present?

    red.update(idp: true)
    red.known_entity.tag_as(Tag::IdP)
  end

  def set_as_aa(red, ed_node)
    return unless ed_node.xpath(ATTRIBUTE_AUTHORITY_DESCRIPTOR_XPATH).present?

    if ed_node.xpath(IDP_SSO_DESCRIPTOR_XPATH).present?
      red.update(standalone_aa: false)
      red.known_entity.tag_as(Tag::AA)
    else
      red.update(standalone_aa: true)
      red.known_entity.tag_as(Tag::StandaloneAA)
    end
  end

  def set_as_sp(red, ed_node)
    return unless ed_node.xpath(SP_SSO_DESCRIPTOR_XPATH).present?

    red.update(sp: true)
    red.known_entity.tag_as(Tag::SP)
  end
end
