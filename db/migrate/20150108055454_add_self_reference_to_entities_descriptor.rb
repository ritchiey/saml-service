Sequel.migration do
  change do
    alter_table :entities_descriptors do
      add_foreign_key :parent_entities_descriptor_id, :entities_descriptors,
                      null: true,
                      foreign_key_constraint_name: 'enities_des_parent_fkey'
    end
  end
end
