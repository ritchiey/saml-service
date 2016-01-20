Sequel.migration do
  change do

    create_table :entity_descriptors do
      primary_key :id
      foreign_key :entities_descriptor_id, :entities_descriptors, null: false,
                  foreign_key_constraint_name: 'entities_descriptors_id_key'
      foreign_key :organization_id, :organizations,
                  foreign_key_constraint_name: 'organization_id_key'

      String :extensions, text: true

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
