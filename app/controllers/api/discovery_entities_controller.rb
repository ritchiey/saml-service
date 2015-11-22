module API
  class DiscoveryEntitiesController < APIController
    skip_before_action :ensure_authenticated

    def index
      public_action
      @identity_providers = identity_providers
      @service_providers = service_providers
    end

    private

    def service_providers
      entities_with_role_descriptor(:sp_sso_descriptors)
    end

    def identity_providers
      entities_with_role_descriptor(:idp_sso_descriptors)
    end

    def entities_with_role_descriptor(table)
      EntityDescriptor.dataset.qualify.distinct(:id)
        .join(table, entity_descriptor_id: :id)
        .to_a
    end
  end
end
