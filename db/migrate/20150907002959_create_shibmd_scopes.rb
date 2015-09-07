Sequel.migration do
  change do

    create_table :scopes do
      primary_key :id
      foreign_key :role_descriptor_id, :role_descriptors, null: false,
            foreign_key_constraint_name: 'scope_rd_fkey'

      String :value, null: false
      Boolean :regexp, default: false, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end

  end
end
