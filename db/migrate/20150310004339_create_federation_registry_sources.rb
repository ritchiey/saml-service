Sequel.migration do
  change do
    create_table :federation_registry_sources do
      primary_key :id

      foreign_key :entity_source_id, :entity_sources, null: false

      String :hostname, null: false
      String :secret, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end
