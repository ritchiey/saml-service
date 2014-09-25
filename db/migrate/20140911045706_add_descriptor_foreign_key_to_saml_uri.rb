Sequel.migration do
  change do
    alter_table :saml_uris do
      add_foreign_key :role_descriptor_id, :role_descriptors,
                      foreign_key_constraint_name: 'uri_descriptor_id_fkey'
    end
  end
end
