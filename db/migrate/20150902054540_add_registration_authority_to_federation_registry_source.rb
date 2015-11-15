Sequel.migration do
  change do
    alter_table :federation_registry_sources do
      add_column :registration_authority, String, null: false
    end
  end
end
