Sequel.migration do 
  change do

    create_table :single_sign_on_services do
      primary_key :id
    end

  end
end