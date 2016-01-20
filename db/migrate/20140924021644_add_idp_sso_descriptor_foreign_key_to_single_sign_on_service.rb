Sequel.migration do
  change do
    alter_table :single_sign_on_services do
      add_foreign_key :idp_sso_descriptor_id, :idp_sso_descriptors, null: false,
                      foreign_key_constraint_name: 'idp_ssos_fkey'
    end
  end
end
