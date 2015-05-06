Sequel.migration do
  up do
    alter_table :tags do
      drop_foreign_key :entity_descriptor_id
      drop_constraint('name_entity_descriptor_id_un', type: :unique)
    end
  end

  down do
    alter_table :tags do
      add_foreign_key :entity_descriptor_id, :entity_descriptors
      add_unique_constraint([:name, :entity_descriptor_id],
                            :name=>'name_entity_descriptor_id_un')
    end
  end
end
