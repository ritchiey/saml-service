Sequel.migration do
  change do

    create_table :attribute_profiles do
      primary_key :id
      foreign_key :idp_sso_descriptor_id, :idp_sso_descriptors,
                  null: true, foreign_key_constraint_name: 'ap_idp_fkey'
    end

  end
end
