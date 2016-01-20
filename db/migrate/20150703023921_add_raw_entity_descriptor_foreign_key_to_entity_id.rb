Sequel.migration do
  change do
    alter_table :entity_ids do
      add_foreign_key :raw_entity_descriptor_id, :raw_entity_descriptors, null: true,
                      foreign_key_constraint_name: 'red_eid_fkey'
    end
  end
end
