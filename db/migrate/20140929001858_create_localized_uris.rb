Sequel.migration do
  change do

    create_table :localized_uris do
      primary_key :id

      Text :uri, null: false
      String :lang, null: false

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
