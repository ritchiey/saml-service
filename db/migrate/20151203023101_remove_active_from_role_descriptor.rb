Sequel.migration do
  up do
    alter_table :role_descriptors do
      drop_column :active
    end
  end

  down do
    alter_table :role_descriptors do
      add_column :active, TrueClass
    end
  end
end
