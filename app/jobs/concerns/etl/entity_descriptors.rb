module ETL
  module EntityDescriptors
    def entity_descriptors(o, org_data)
      org_data[:saml][:entity_descriptors].each do |ed_ref|
        ed_data = fr_entity_descriptors[ed_ref[:id]]
        ed = create_or_update(o, EntityDescriptor.dataset, ed_data)

        entity_id(ed, ed_data)
        registration_info(ed)
        idp_sso_descriptors(ed, ed_data)
      end
    end

    def create_or_update(o, ds, ed_data)
      create_or_update_by_fr_id(ds, ed_data[:id], ed_attrs(ed_data)) do |obj|
        obj.organization = o
        obj.known_entity = known_entity(ed_data)
      end
    end

    def known_entity(ed_data)
      KnownEntity.create(entity_source: source, active: ed_data[:active])
    end

    def ed_attrs(ed_data)
      { created_at: Time.parse(ed_data[:created_at]),
        enabled: ed_data[:functioning] }
    end

    def entity_id(ed, ed_data)
      return ed.entity_id.update(uri: ed_data[:entity_id]) if ed.entity_id
      EntityId.create(uri: ed_data[:entity_id], entity_descriptor: ed)
    end

    def registration_info(ed)
      return if ed.registration_info
      ri = MDRPI::RegistrationInfo.create(registration_authority:
                                          @fr_source.registration_authority,
                                          entity_descriptor: ed)
      MDRPI::RegistrationPolicy.create(
        registration_info: ri,
        uri: @fr_source.registration_policy_uri,
        lang: @fr_source.registration_policy_uri_lang)
    end
  end
end
