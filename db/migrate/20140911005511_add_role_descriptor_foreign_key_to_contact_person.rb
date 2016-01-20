Sequel.migration do
  change do
    alter_table :contact_people do
      add_foreign_key :role_descriptor_id, :role_descriptors,
                      foreign_key_constraint_name: 'rd_cp_fkey'
    end
  end
end
