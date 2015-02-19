Sequel.migration do
  change do
    alter_table :tags do
      add_foreign_key :entities_descriptor_id, :entities_descriptors
      add_unique_constraint([:name, :entities_descriptor_id],
                            :name=>'name_entities_descriptor_id_un')
    end
  end
end
