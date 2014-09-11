Sequel.migration do
  change do
    alter_table :saml_uris do
      add_foreign_key :sso_descriptor_id, :sso_descriptors,
                      foreign_key_constraint_name: 'sso_name_id_fkey'
    end
  end
end
