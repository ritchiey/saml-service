Sequel.migration do
  change do
    tables = %i(ca_key_infos entity_attributes publication_infos
                registration_infos)

    tables.each do |table|
      rename_column table, :entities_descriptor_id, :metadata_instance_id
    end

    alter_table :entity_descriptors do
      drop_foreign_key :entities_descriptor_id,
                       name: 'entities_descriptors_id_key'
      add_foreign_key :known_entity_id, :known_entities, null: false,
                      foreign_key_constraint_name: 'known_entities_id_key'
    end
  end
end
