Sequel.migration do
  up do
    alter_table :entities_descriptors do
      drop_foreign_key :parent_entities_descriptor_id,
                       name: 'enities_des_parent_fkey'
    end
    rename_table :entities_descriptors, :metadata_instances
  end

  down do
    rename_table :metadata_instances, :entities_descriptors
    alter_table :entities_descriptors do
      add_foreign_key :parent_entities_descriptor_id, :entities_descriptors,
                      null: true,
                      foreign_key_constraint_name: 'enities_des_parent_fkey'
    end
  end
end
