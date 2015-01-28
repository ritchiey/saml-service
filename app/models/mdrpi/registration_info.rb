module MDRPI
  class RegistrationInfo < Sequel::Model
    include Parents

    many_to_one :entities_descriptor, class: 'EntitiesDescriptor'
    many_to_one :entity_descriptor, class: 'EntityDescriptor'

    one_to_many :registration_policies

    def validate
      super
      validates_presence [:registration_authority, :created_at, :updated_at]

      return if new?
      validates_presence :registration_policies
      single_parent [:entities_descriptor, :entity_descriptor]
    end

    def registration_instant_utc
      return created_at.utc unless registration_instant
      registration_instant.utc
    end
  end
end
