Sequel.migration do
  change do
    alter_table :raw_entity_descriptors do
      add_column :enabled, TrueClass, default: false
    end
  end
end
