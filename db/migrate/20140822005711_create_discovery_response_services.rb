Sequel.migration do 
  change do

    create_table :discovery_response_services do
      primary_key :id
    end

  end
end