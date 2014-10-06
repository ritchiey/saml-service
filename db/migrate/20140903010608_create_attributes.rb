Sequel.migration do
  change do

    create_table :attributes do
      primary_key :id

      String :name, null: false
      String :friendly_name
      String :legacy_name
      String :oid
      String :description

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
