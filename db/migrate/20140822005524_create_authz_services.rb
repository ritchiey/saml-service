Sequel.migration do 
  change do

    create_table :authz_services do
      primary_key :id
    end

  end
end