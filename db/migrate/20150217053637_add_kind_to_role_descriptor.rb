Sequel.migration do
  change do
    alter_table :role_descriptors do
      add_column :kind, String
    end
  end
end
