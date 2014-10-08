Sequel.migration do
  change do

    create_table :entity_ids do
      primary_key :id
      foreign_key :entity_descriptor_id, :entity_descriptors,
                  null: false, foreign_key_constraint_name: 'eid_ed_fkey'
    end

  end
end
