Sequel.migration do
  change do
    alter_table :attributes do
      add_foreign_key :attribute_authority_descriptor_id,
                      :attribute_authority_descriptors, null: true,
                      foreign_key_constraint_name: 'aad_attr_fkey'

    end
  end
end
