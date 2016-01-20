Sequel.migration do
  change do

    create_table :organizations do
      primary_key :id
      String :name, null: false
      String :display_name, null: false
      String :url, null: false

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
