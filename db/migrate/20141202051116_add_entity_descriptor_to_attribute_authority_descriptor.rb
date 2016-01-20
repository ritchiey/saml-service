Sequel.migration do
  change do
    alter_table :attribute_authority_descriptors do
      add_foreign_key :entity_descriptor_id, :entity_descriptors, null: true,
                      foreign_key_constraint_name: 'ed_aad_fkey'
    end
  end
end
