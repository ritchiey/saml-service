Sequel.migration do
  change do
    alter_table :metadata_instances do
      add_column :primary_tag, String, null: false
    end
  end
end
