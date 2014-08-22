Sequel.migration do 
  change do

    create_table :assertion_consumer_services do
      primary_key :id
    end

  end
end