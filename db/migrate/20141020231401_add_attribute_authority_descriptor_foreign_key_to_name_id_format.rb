Sequel.migration do
  change do
    alter_table :name_id_formats do
      add_foreign_key :attribute_authority_descriptor_id,
                      :attribute_authority_descriptors, null: true,
                      foreign_key_constraint_name: 'aad_nidf_fkey'
    end
  end
end
