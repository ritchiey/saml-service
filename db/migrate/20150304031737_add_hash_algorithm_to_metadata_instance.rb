Sequel.migration do
  change do
    alter_table :metadata_instances do
      add_column :hash_algorithm, String, null: false
    end
  end
end
