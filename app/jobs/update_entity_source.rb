require 'metadata/schema'

class UpdateEntitySource
  include Metadata::Schema

  ENTITY_DESCRIPTOR_XPATH =
    '//*[local-name() = "EntityDescriptor" and ' \
    'namespace-uri() = "urn:oasis:names:tc:SAML:2.0:metadata"]'
    .freeze
  private_constant :ENTITY_DESCRIPTOR_XPATH

  def self.perform(id: id)
    new.perform(id: id)
  end

  def perform(id: id)
    source = EntitySource[id]
    untouched = source.known_entities.to_a

    document(source).xpath(ENTITY_DESCRIPTOR_XPATH).each do |node|
      entity = known_entity(source, node)
      update_raw_entity_descriptor(entity, node)

      untouched.reject! { |e| e.id == entity.id }
    end

    sweep(untouched)
  end

  private

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

  def known_entity(source, node)
    entity_id = EntityId.find(uri: node['entityID'])
    return entity_id.parent.known_entity if entity_id

    KnownEntity.create(entity_source: source, active: true)
  end

  def update_raw_entity_descriptor(entity, node)
    if entity.raw_entity_descriptor
      entity.raw_entity_descriptor.update(xml: node.canonicalize)
    else
      red = RawEntityDescriptor.create(known_entity: entity,
                                       xml: node.canonicalize)
      EntityId.create(uri: node['entityID'], raw_entity_descriptor: red)
    end
  end

  def sweep(untouched)
    KnownEntity.where(id: untouched.map(&:id)).each do |ke|
      ke.raw_entity_descriptor.entity_id.try(:destroy)
      ke.raw_entity_descriptor.try(:destroy)
      ke.destroy
    end
  end
end
