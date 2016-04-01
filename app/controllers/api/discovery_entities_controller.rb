module API
  class DiscoveryEntitiesController < APIController
    skip_before_action :ensure_authenticated

    def index
      Sequel::Model.db.transaction(isolation: :repeatable) do
        public_action
        @identity_provider_entities =
          ed_containing_idp.select(&:functioning?) +
          red_containing_idp.select(&:functioning?)
        @service_provider_entities =
          ed_containing_sp.select(&:functioning?) +
          red_containing_sp.select(&:functioning?)
      end
    end

    private

    COMMON_EAGER_FETCH = {
      entity_id: [],
      known_entity: :tags,
      role_descriptors: [],
      organization: [],
      registration_info: []
    }

    SP_EAGER_FETCH = COMMON_EAGER_FETCH.merge(
      sp_sso_descriptors: {
        ui_info: %i(logos descriptions display_names information_urls
                    privacy_statement_urls),
        discovery_response_services: []
      }
    )

    IDP_EAGER_FETCH = COMMON_EAGER_FETCH.merge(
      idp_sso_descriptors: {
        ui_info: %i(logos descriptions display_names),
        disco_hints: %i(geolocation_hints domain_hints)
      }
    )

    RAW_COMMON_EAGER_FETCH = {
      entity_id: [],
      known_entity: :tags
    }

    RAW_IDP_EAGER_FETCH = RAW_COMMON_EAGER_FETCH

    RAW_SP_EAGER_FETCH = RAW_COMMON_EAGER_FETCH

    private_constant :COMMON_EAGER_FETCH, :SP_EAGER_FETCH, :IDP_EAGER_FETCH,
                     :RAW_COMMON_EAGER_FETCH, :RAW_IDP_EAGER_FETCH,
                     :RAW_SP_EAGER_FETCH

    def ed_containing_sp
      entities_with_role_descriptor(:sp_sso_descriptors)
        .eager(SP_EAGER_FETCH).all
    end

    def red_containing_sp
      RawEntityDescriptor.where(sp: true).eager(known_entity: :tags)
        .eager(RAW_SP_EAGER_FETCH).all
    end

    def ed_containing_idp
      entities_with_role_descriptor(:idp_sso_descriptors)
        .eager(IDP_EAGER_FETCH).all
    end

    def red_containing_idp
      RawEntityDescriptor.where(idp: true).eager(known_entity: :tags)
        .eager(RAW_IDP_EAGER_FETCH).all
    end

    def entities_with_role_descriptor(table)
      EntityDescriptor.qualify.distinct(:id)
        .join(table, entity_descriptor_id: :id)
    end
  end
end
