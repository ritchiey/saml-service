Sequel.migration do 
  change do

    create_table :attribute_authority_descriptors do
      primary_key :id
    end

  end
end