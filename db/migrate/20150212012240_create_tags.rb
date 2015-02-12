Sequel.migration do 
  change do

    create_table :tags do
      primary_key :id
      String :name, null: false
      foreign_key :entity_descriptor_id, :entity_descriptors
      foreign_key :role_descriptor_id, :role_descriptors
      DateTime :created_at
      DateTime :updated_at
    end

  end
end
