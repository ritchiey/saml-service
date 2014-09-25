Sequel.migration do
  change do
    alter_table :assertion_id_request_services do
      add_foreign_key :idp_sso_descriptor_id, :idp_sso_descriptors, null: true,
                      foreign_key_constraint_name: 'idp_aidr_fkey'
    end
  end
end
