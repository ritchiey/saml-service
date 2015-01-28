Sequel.migration do
  change do

    create_table :endpoints do
      primary_key :id
      String :binding, null: false
      String :location, null: false
      String :response_location

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
