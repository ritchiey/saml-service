class EntitiesDescriptor < Sequel::Model
  many_to_one :parent_entities_descriptor, class: self
  one_to_many :entities_descriptors, key: :parent_entities_descriptor_id,
                                     class: self

  one_to_many :entity_descriptors
  one_to_many :ca_key_infos

  one_to_one :registration_info, class: 'MDRPI::RegistrationInfo'
  one_to_one :publication_info, class: 'MDRPI::PublicationInfo'
  one_to_one :entity_attribute, class: 'MDATTR::EntityAttribute'

  def validate
    super
    validates_presence [:name, :created_at, :updated_at]
    validates_presence :ca_verify_depth if ca_keys?
    validates_presence :publication_info unless new? || sibling?
  end

  def ca_keys?
    ca_key_infos.try(:present?)
  end

  def registration_info?
    registration_info.try(:present?)
  end

  def entity_attribute?
    entity_attribute.try(:present?)
  end

  def sibling?
    parent_entities_descriptor.try(:present?)
  end

  def locate_publication_info
    publication_info || parent_entities_descriptor.locate_publication_info
  end

  def self.with_any_tag(tags)
    qualify.distinct.join(:tags, entities_descriptor_id: :id, name: tags).all
  end
end
