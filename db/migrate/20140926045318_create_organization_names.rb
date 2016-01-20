Sequel.migration do
  change do

    create_table :organization_names do
      primary_key :id
      foreign_key :organization_id, :organizations,
                  null: false, foreign_key_constraint_name: 'org_on_ln_fkey'

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
