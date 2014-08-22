Sequel.migration do 
  change do

    create_table :attribute_services do
      primary_key :id
    end

  end
end