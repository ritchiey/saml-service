Sequel.migration do
  change do
    alter_table :metadata_instances do
      add_column :cache_period, Integer, null: false, default: 21600
    end
  end
end
