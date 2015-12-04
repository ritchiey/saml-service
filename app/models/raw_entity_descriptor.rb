require 'metadata/schema'

class RawEntityDescriptor < Sequel::Model
  include Metadata::Schema

  many_to_one :known_entity

  one_to_one :entity_id

  plugin :association_dependencies, entity_id: :destroy

  alias_method :idp?, :idp
  alias_method :sp?, :sp
  alias_method :standalone_aa?, :standalone_aa

  def validate
    super
    validates_presence [:known_entity, :xml, :created_at, :updated_at]
    validates_unique :known_entity
    validates_presence :entity_id, allow_missing: new?
    # Any more than 65535, the column type needs to be upgraded.
    validates_max_length 65_535, :xml
    validate_xml
  end

  def functioning?
    valid? && enabled
  end

  def validate_xml
    return if xml.blank?

    doc = Nokogiri::XML.parse(xml)
    validate_document_contents(doc)

    return if metadata_schema.valid?(doc)
    errors.add(:xml, 'is not valid per the XML Schema')
  end

  def validate_document_contents(doc)
    unless doc.root.name == 'EntityDescriptor'
      errors.add(:xml, 'must have <EntityDescriptor> as the root')
    end

    ns = doc.root.namespace.try(:href)
    return if ns == 'urn:oasis:names:tc:SAML:2.0:metadata'
    errors.add(:xml, 'must have SAML 2.0 metadata namespace on root element')
  end
end
