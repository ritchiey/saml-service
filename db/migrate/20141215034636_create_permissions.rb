Sequel.migration do
  change do

    create_table :permissions do
      primary_key :id
      foreign_key :role_id, :roles, null: false,
                  foreign_key_constraint_name: 'perm_role_fkey'

      String :value, null: false

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
