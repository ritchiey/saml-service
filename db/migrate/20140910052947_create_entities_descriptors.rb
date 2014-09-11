Sequel.migration do
  change do

    create_table :entities_descriptors do
      primary_key :id

      String :identifier, null: false
      String :name, null: false
      String :extensions, text: true

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
