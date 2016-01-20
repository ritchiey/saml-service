Sequel.migration do
  change do
    add_column :entity_sources, :url, String, null: true
  end
end
