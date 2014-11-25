Sequel.migration do
  change do

    create_table :disco_hints do
      primary_key :id
      foreign_key :idp_sso_descriptor_id, :idp_sso_descriptors, null: false,
                  foreign_key_constraint_name: 'mdui_dh_idp_fkey'

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
