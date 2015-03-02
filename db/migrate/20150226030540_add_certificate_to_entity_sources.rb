Sequel.migration do
  change do
    add_column :entity_sources, :certificate, String, null: true, size: 4096
  end
end
