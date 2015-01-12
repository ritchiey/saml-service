module MDRPI
  class PublicationInfo < Sequel::Model
    include Parents

    many_to_one :entities_descriptor, class: 'EntitiesDescriptor'
    many_to_one :entity_descriptor, class: 'EntityDescriptor'

    one_to_many :usage_policies

    def validate
      super
      validates_presence [:publisher, :created_at, :updated_at]
      return if new?

      validates_presence :usage_policies
      single_parent [:entities_descriptor, :entity_descriptor]
    end
  end
end
