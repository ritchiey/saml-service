Sequel.migration do
  change do
    alter_table :tags do
      add_unique_constraint([:name, :entity_descriptor_id],
                            :name=>'name_entity_descriptor_id_un')
      add_unique_constraint([:name, :role_descriptor_id],
                            :name=>'name_role_descriptor_id_un')
    end
  end
end
