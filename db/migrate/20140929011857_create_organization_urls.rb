Sequel.migration do
  change do

    create_table :organization_urls do
      primary_key :id
      foreign_key :organization_id, :organizations,
                  null: false, foreign_key_constraint_name: 'org_ou_lu_fkey'

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
