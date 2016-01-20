Sequel.migration do
  change do
    alter_table :encryption_methods do
      add_foreign_key :key_descriptor_id, :key_descriptors, null: false,
                      foreign_key_constraint_name: 'key_descriptors_enc_fkey'
    end
  end
end
