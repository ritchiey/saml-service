class EntityDescriptor < Sequel::Model
  many_to_one :entities_descriptor
  many_to_one :organization

  one_to_many :additional_metadata_locations
  one_to_many :contact_people
  one_to_many :role_descriptors
  one_to_many :idp_sso_descriptors
  one_to_many :sp_sso_descriptors
  one_to_many :attribute_authority_descriptors

  one_to_one :entity_id

  one_to_one :registration_info, class: 'MDRPI::RegistrationInfo'
  one_to_one :publication_info, class: 'MDRPI::PublicationInfo'
  one_to_one :entity_attribute, class: 'MDATTR::EntityAttribute'

  def validate
    super
    validates_presence [:entities_descriptor, :created_at, :updated_at]
    validates_presence :entity_id, allow_missing: new?
    validates_presence :role_descriptors, allow_missing: new?
    validates_presence :organization, allow_missing: new?
    validates_presence :registration_info, allow_missing: new?

    validate_technical_contact
  end

  def validate_technical_contact
    return if new?
    error_message = 'must specify a technical contact'
    errors.add(:contact_people, error_message) if technical_contact_count == 0
  end

  def locate_publication_info
    publication_info || entities_descriptor.locate_publication_info
  end

  def entity_attribute?
    entity_attribute.try(:present?)
  end

  def self.with_tag(tags)
    Tag.where(name: tags).exclude(entity_descriptor_id: nil)
      .group(:entity_descriptor_id)
      .map(&:entity_descriptor)
  end

  protected

  def technical_contact_count
    ContactPerson.join(:entity_descriptors, id: :entity_descriptor_id)
      .where(Sequel.qualify(:entity_descriptors, :id) => id)
      .and(Sequel.qualify(:contact_people, :contact_type_id) =>
           ContactPerson::TYPE[:technical])
      .count
  end
end
