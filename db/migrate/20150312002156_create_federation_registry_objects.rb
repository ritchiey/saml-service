Sequel.migration do
  change do
    create_table :federation_registry_objects do
      primary_key :id

      String :object_type, null: false
      Integer :object_id, null: false
      Integer :fr_id, null: false
    end
  end
end
