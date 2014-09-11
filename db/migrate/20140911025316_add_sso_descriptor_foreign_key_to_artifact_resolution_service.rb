Sequel.migration do
  change do
    alter_table :artifact_resolution_services do
      add_foreign_key :sso_descriptor_id, :sso_descriptors,
                      foreign_key_constraint_name: 'sso_ars_fkey'
    end
  end
end
