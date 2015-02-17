Sequel.migration do
  change do
    create_table :entity_sources do
      primary_key :id
      Integer :rank, null: false
      TrueClass :active, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end
