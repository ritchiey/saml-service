Sequel.migration do 
  change do

    create_table :sso_descriptors do
      primary_key :id
    end

  end
end