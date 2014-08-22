Sequel.migration do 
  change do

    create_table :assertion_id_request_services do
      primary_key :id
    end

  end
end