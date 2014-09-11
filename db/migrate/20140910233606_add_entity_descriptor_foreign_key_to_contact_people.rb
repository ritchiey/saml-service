Sequel.migration do
  change do
    alter_table :contact_people do
      add_foreign_key :entity_descriptor_id, :entity_descriptors,
                      foreign_key_constraint_name: 'ed_id_cp_fkey'
    end
  end
end
