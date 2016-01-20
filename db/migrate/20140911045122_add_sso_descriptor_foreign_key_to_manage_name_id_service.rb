Sequel.migration do
  change do
    alter_table :manage_name_id_services do
      add_foreign_key :sso_descriptor_id, :sso_descriptors,
                      foreign_key_constraint_name: 'sso_mnid_fkey'
    end
  end
end
