Sequel.migration do 
  change do

    create_table :artifact_resolution_services do
      primary_key :id
    end

  end
end