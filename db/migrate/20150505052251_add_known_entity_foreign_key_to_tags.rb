Sequel.migration do
  up do
    alter_table :tags do
      add_foreign_key :known_entity_id, :known_entities
      add_unique_constraint([:name, :known_entity_id],
                            :name=>'name_known_entity_id_un')
    end
  end

  down do
    alter_table :tags do
      drop_foreign_key :known_entity_id
      drop_constraint('name_known_entity_id_un', type: :unique)
    end
  end
end
