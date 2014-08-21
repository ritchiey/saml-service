Sequel.migration do
  change do

    # 'extends' endpoints
    create_table :indexed_endpoints do
      primary_key :id
      TrueClass :is_default, null: false
      Integer :index, null: false
    end

  end
end
