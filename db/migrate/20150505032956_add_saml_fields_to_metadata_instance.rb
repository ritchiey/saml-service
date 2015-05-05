Sequel.migration do
  change do
    alter_table :metadata_instances do
      add_column :federation_identifier, String, null: false
      add_column :validity_period, Integer, null: false
      drop_column :identifier
    end
  end
end
