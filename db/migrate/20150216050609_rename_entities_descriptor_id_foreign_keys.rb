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
      add_foreign_key :entity_source_id, :entity_sources, null: false,
                      foreign_key_constraint_name: 'entity_sources_id_key'
    end
  end
end
