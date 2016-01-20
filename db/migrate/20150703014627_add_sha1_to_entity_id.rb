Sequel.migration do
  change do
    alter_table :entity_ids do
      add_column :sha1, String, null: false
    end
  end
end
