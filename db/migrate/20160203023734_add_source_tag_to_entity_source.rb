Sequel.migration do
  change do
    alter_table :entity_sources do
      add_column :source_tag, String, null: false, unique: true, default: 'aaf'
    end
  end
end
