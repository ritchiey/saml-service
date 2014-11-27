module MDRPI
  class RegistrationInfo < Sequel::Model
    include Parents

    many_to_one :entities_descriptor, class: 'EntitiesDescriptor'
    many_to_one :entity_descriptor, class: 'EntityDescriptor'

    def validate
      super
      validates_presence [:registration_authority, :created_at, :updated_at]
      return if new?

      single_parent [:entities_descriptor, :entity_descriptor]
    end
  end
end
