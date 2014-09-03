Sequel.migration do
  change do

    create_table :attribute_values do
      primary_key :id
      String :value
      TrueClass :approved

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
