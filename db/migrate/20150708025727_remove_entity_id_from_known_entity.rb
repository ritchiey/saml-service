Sequel.migration do
  up do
    alter_table :known_entities do
      drop_column :entity_id
    end
  end

  down do
    alter_table :known_entities do
      add_column :entity_id, String
    end
  end
end
