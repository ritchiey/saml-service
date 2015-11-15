Sequel.migration do
  change do
    alter_table :federation_registry_sources do
      add_column :registration_policy_uri, String, null: false
      add_column :registration_policy_uri_lang, String, null: false
    end
  end
end
