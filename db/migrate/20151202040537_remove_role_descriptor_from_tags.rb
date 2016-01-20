Sequel.migration do
  up do
    alter_table :tags do
      drop_constraint :name_role_descriptor_id_un, type: :unique
      drop_foreign_key :role_descriptor_id
    end
  end

  down do
    alter_table :tags do
      add_foreign_key :role_descriptor_id, :role_descriptors
      add_unique_constraint([:name, :role_descriptor_id],
                             name: 'name_role_descriptor_id_un')
    end
  end
end
