Sequel.migration do
  change do
    create_table :entity_sources do
      primary_key :id
      TrueClass :active, null: false
    end
  end
end
