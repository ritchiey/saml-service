# frozen_string_literal: true

module SetSAMLTypeFromXML
  def self.xpath_for_metadata_element(name)
    "//*[local-name() = \"#{name}\" and " \
    'namespace-uri() = "urn:oasis:names:tc:SAML:2.0:metadata"]'
  end

  ENTITY_DESCRIPTOR_XPATH = xpath_for_metadata_element('EntityDescriptor')
  IDP_SSO_DESCRIPTOR_XPATH = xpath_for_metadata_element('IDPSSODescriptor')
  SP_SSO_DESCRIPTOR_XPATH = xpath_for_metadata_element('SPSSODescriptor')
  ATTRIBUTE_AUTHORITY_DESCRIPTOR_XPATH =
    xpath_for_metadata_element('AttributeAuthorityDescriptor')

  private_constant :ENTITY_DESCRIPTOR_XPATH, :IDP_SSO_DESCRIPTOR_XPATH,
                   :ATTRIBUTE_AUTHORITY_DESCRIPTOR_XPATH,
                   :SP_SSO_DESCRIPTOR_XPATH

  def set_saml_type(red, ed_node)
    tags = desired_entity_tags(ed_node)
    untags = all_entity_tags - tags

    red.update(idp: tags.include?(Tag::IDP),
               sp: tags.include?(Tag::SP),
               standalone_aa: tags.include?(Tag::STANDALONE_AA))

    ke = red.known_entity
    tags.each { |tag| ke.tag_as(tag) }
    untags.each { |tag| ke.untag_as(tag) }
  end

  def desired_entity_tags(ed_node)
    tags = []

    if entity_has_idp_role?(ed_node)
      tags << Tag::IDP
      tags << Tag::AA if entity_has_aa_role?(ed_node)
    elsif entity_has_aa_role?(ed_node)
      tags << Tag::STANDALONE_AA
    end

    tags << Tag::SP if entity_has_sp_role?(ed_node)

    tags
  end

  def all_entity_tags
    [Tag::IDP, Tag::AA, Tag::STANDALONE_AA, Tag::SP]
  end

  def entity_has_idp_role?(ed_node)
    ed_node.xpath(IDP_SSO_DESCRIPTOR_XPATH).present?
  end

  def entity_has_aa_role?(ed_node)
    ed_node.xpath(ATTRIBUTE_AUTHORITY_DESCRIPTOR_XPATH).present?
  end

  def entity_has_sp_role?(ed_node)
    ed_node.xpath(SP_SSO_DESCRIPTOR_XPATH).present?
  end
end
