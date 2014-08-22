Sequel.migration do 
  change do

    create_table :name_id_mapping_services do
      primary_key :id
    end

  end
end