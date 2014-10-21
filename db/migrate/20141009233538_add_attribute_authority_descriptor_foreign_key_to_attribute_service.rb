Sequel.migration do
  change do
    alter_table :attribute_services do
      add_foreign_key :attribute_authority_descriptor_id,
                      :attribute_authority_descriptors, null: false,
                      foreign_key_constraint_name: 'aad_as_fkey'
    end
  end
end
