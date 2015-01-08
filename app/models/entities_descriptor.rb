class EntitiesDescriptor < Sequel::Model
  many_to_one :parent_entities_descriptor, class: self
  one_to_many :entities_descriptors, key: :parent_entities_descriptor_id,
                                     class: self

  one_to_many :entity_descriptors

  one_to_one :registration_info, class: 'MDRPI::RegistrationInfo'
  one_to_one :publication_info, class: 'MDRPI::PublicationInfo'
  one_to_one :entity_attribute, class: 'MDATTR::EntityAttribute'

  def validate
    super
    validates_presence [:name, :created_at, :updated_at]
  end
end
