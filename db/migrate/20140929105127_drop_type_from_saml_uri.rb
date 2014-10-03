Sequel.migration do
  up do
    alter_table :saml_uris do
      drop_column :type
    end
  end

  down do
    alter_table :saml_uris do
      add_column :type, Integer, null: false
    end
  end
end
