Sequel.migration do 
  change do

    create_table :manage_name_id_services do
      primary_key :id
    end

  end
end