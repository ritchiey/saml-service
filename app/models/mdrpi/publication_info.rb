module MDRPI
  class PublicationInfo < Sequel::Model
    include Parents

    many_to_one :entities_descriptor, class: 'EntitiesDescriptor'
    many_to_one :entity_descriptor, class: 'EntityDescriptor'

    def validate
      super
      validates_presence [:publisher, :created_at, :updated_at]
      return if new?

      single_parent [:entities_descriptor, :entity_descriptor]
    end
  end
end
