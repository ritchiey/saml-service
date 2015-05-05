Sequel.migration do
  change do
    alter_table :metadata_instances do
      add_column :all_entities, TrueClass, null: false, default: true
    end
  end
end
