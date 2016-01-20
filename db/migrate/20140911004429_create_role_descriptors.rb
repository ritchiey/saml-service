Sequel.migration do
  change do

    create_table :role_descriptors do
      primary_key :id
      foreign_key :entity_descriptor_id, :entity_descriptors, null: false,
                  foreign_key_constraint_name: 'ed_rd_key'
      foreign_key :organization_id, :organizations,
                  foreign_key_constraint_name: 'o_rd_key'

      String :error_url
      TrueClass :active

      String :extensions, text: true

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
