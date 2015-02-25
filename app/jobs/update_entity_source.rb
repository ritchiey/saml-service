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
    document(source).xpath(ENTITY_DESCRIPTOR_XPATH).each do |node|
      entity = known_entity(source, node)
      update_raw_entity_descriptor(entity, node)
    end
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
    return doc if errors.empty?

    fail("Unable to update EntitySource(id=#{source.id} url=#{source.url}). " \
         'Schema validation errors prevented processing of the metadata ' \
         "document. Errors were: #{errors.join(', ')}")
  end

  def known_entity(source, node)
    attrs = { entity_source: source, entity_id: node['entityID'] }
    KnownEntity.find_or_create(attrs) { |e| e.active = true }
  end

  def update_raw_entity_descriptor(entity, node)
    red = entity.raw_entity_descriptor ||
          RawEntityDescriptor.new(known_entity: entity)
    red.update(xml: node.canonicalize)
  end
end
