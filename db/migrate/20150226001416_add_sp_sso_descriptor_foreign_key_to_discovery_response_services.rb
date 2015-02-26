Sequel.migration do
  change do
    alter_table :discovery_response_services do
      add_foreign_key :sp_sso_descriptor_id, :sp_sso_descriptors, null: false,
                      foreign_key_constraint_name: 'sp_drs_fkey'
    end
  end
end
