Sequel.migration do
  change do
    alter_table :entity_descriptors do
      add_column :enabled, TrueClass, default: false
    end
  end
end
