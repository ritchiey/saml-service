Sequel.migration do
  change do
    alter_table :additional_metadata_locations do
      add_foreign_key :entity_descriptor_id, :entity_descriptors, null: false,
                      foreign_key_constraint_name: 'entity_descriptors_id_key'
    end
  end
end
