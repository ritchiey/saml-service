Sequel.migration do
  change do
    alter_table :key_descriptors do
      add_foreign_key :role_descriptor_id, :role_descriptors,
                      foreign_key_constraint_name: 'rd_kd_fkey'
    end
  end
end
