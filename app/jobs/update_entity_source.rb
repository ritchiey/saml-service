require 'metadata/schema'

class UpdateEntitySource
  include Metadata::Schema

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

  def self.perform(id:, primary_tag:)
    new.perform(id: id, primary_tag: primary_tag)
  end

  def perform(id:, primary_tag:)
    Sequel::Model.db.transaction do
      source = EntitySource[id]
      untouched = source.known_entities.to_a

      document(source).xpath(ENTITY_DESCRIPTOR_XPATH).each do |node|
        process_entity_descriptor(primary_tag, source, node, untouched)
      end

      sweep(untouched)
    end
  end

  private

  def process_entity_descriptor(primary_tag, source, node, untouched)
    # We represent each EntityDescriptor as a standalone piece of XML in the
    # database for future processing.
    #
    # This approach (creating new document) reduces C14N calculation per
    # EntityDescriptor by ~99.3%
    partial_document = Nokogiri::XML::Document.new
    partial_document.root = node

    ke = known_entity(source, partial_document.root, primary_tag)

    update_raw_entity_descriptor(ke, partial_document.root)

    # Changes updated_at timestamp for associated KnownEntity
    # which is used by MDQP for etag generation / caching.
    ke.touch

    untouched.reject! { |e| e.id == ke.id }
  end

  def retrieve(source)
    parsed_url = URI.parse(source.url)
    response = Net::HTTP.get_response(parsed_url)
    return response.body if response.is_a?(Net::HTTPSuccess)

    fail("Unable to update EntitySource(id=#{source.id} url=#{source.url}). " \
         "Response was: #{response.code} #{response.message}")
  end

  def document(source)
    doc = Nokogiri::XML.parse(retrieve(source))

    errors = metadata_schema.validate(doc)
    if errors.empty?
      verify_signature(source, doc)
      return doc
    end

    fail("Unable to update EntitySource(id=#{source.id} url=#{source.url}). " \
         'Schema validation errors prevented processing of the metadata ' \
         "document. Errors were: #{errors.join(', ')}")
  end

  def verify_signature(source, doc)
    return if Xmldsig::SignedDocument.new(doc).validate(source.x509_certificate)

    fail("Unable to update EntitySource(id=#{source.id} url=#{source.url}. " \
         'Signature validation failed.')
  end

  def known_entity(source, root_node, primary_tag)
    entity_id = EntityId.find(uri: root_node['entityID'])
    return entity_id.parent.known_entity if entity_id

    ke = KnownEntity.create(entity_source: source, enabled: true)
    ke.add_tag(Tag.new(name: primary_tag))
    ke
  end

  def update_raw_entity_descriptor(entity, root_node)
    raw_xml = root_node.canonicalize
    if entity.raw_entity_descriptor
      entity.raw_entity_descriptor.update(xml: raw_xml)
    else
      red = RawEntityDescriptor.create(known_entity: entity,
                                       xml: raw_xml, enabled: true)
      EntityId.create(uri: root_node['entityID'], raw_entity_descriptor: red)
    end

    indicate_internal_type(entity.raw_entity_descriptor, root_node)
  end

  def sweep(untouched)
    KnownEntity.where(id: untouched.map(&:id)).each do |ke|
      ke.try(:raw_entity_descriptor).try(:entity_id).try(:destroy)
      ke.try(:raw_entity_descriptor).try(:destroy)
      ke.destroy
    end
  end

  def indicate_internal_type(red, ed_node)
    red.update(idp: true) if ed_node.xpath(IDP_SSO_DESCRIPTOR_XPATH).present?

    if ed_node.xpath(ATTRIBUTE_AUTHORITY_DESCRIPTOR_XPATH).present? &&
       !ed_node.xpath(IDP_SSO_DESCRIPTOR_XPATH).present?
      red.update(standalone_aa: true)
    end

    return unless ed_node.xpath(SP_SSO_DESCRIPTOR_XPATH).present?
    red.update(sp: true)
  end
end
