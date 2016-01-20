Sequel.migration do
  change do
    alter_table :role_descriptors do
      add_column :enabled, :boolean, default: true
    end
  end
end
