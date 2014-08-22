Sequel.migration do 
  change do

    create_table :single_logout_services do
      primary_key :id
    end

  end
end