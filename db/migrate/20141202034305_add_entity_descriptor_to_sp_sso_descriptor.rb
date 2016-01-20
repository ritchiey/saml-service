Sequel.migration do
  change do
    alter_table :sp_sso_descriptors do
      add_foreign_key :entity_descriptor_id, :entity_descriptors, null: true,
                      foreign_key_constraint_name: 'ed_sp_fkey'
    end
  end
end
