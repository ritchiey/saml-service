Sequel.migration do
  TABLES = %w(additional_metadata_locations api_subjects api_subjects_roles artifact_resolution_services assertion_consumer_services assertion_id_request_services attribute_authority_descriptors attribute_consuming_services attribute_profiles attribute_services attribute_values attributes authz_services ca_key_infos contact_people contacts descriptions disco_hints discovery_response_services display_names domain_hints encryption_methods endpoints entity_attributes entity_descriptors entity_ids entity_sources federation_registry_objects federation_registry_sources geolocation_hints idp_sso_descriptors indexed_endpoints information_urls ip_hints key_descriptors key_infos keypairs keyword_lists known_entities localized_names localized_uris logos manage_name_id_services metadata_instances name_formats name_id_formats name_id_mapping_services organization_display_names organization_names organization_urls organizations permissions privacy_statement_urls protocol_supports publication_infos raw_entity_descriptors registration_infos registration_policies requested_attributes role_descriptors roles roles_subjects saml_uris scopes service_descriptions service_names single_logout_services single_sign_on_services sp_sso_descriptors sso_descriptors subjects tags ui_infos usage_policies)

  up do
    TABLES.each do |table|
      run "ALTER TABLE #{table} COLLATE = utf8_bin"
      run "ALTER TABLE #{table} CONVERT TO CHARACTER SET utf8 " \
          'COLLATE utf8_bin'
    end
  end

  down do
  end
end
