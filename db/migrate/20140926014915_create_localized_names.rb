Sequel.migration do
  change do

    create_table :localized_names do
      primary_key :id

      String :value, null: false
      String :lang, null: false

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
