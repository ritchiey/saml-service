Sequel.migration do
  up do
    alter_table :known_entities do
      rename_column :active, :enabled
    end

    alter_table :entity_sources do
      rename_column :active, :enabled
    end
  end

  down do
    alter_table :known_entities do
      rename_column :enabled, :active
    end

    alter_table :entity_sources do
      rename_column :enabled, :active
    end
  end
end
