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
  end
end
