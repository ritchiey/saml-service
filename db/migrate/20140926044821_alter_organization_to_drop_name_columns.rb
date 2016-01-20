Sequel.migration do
  up do
    alter_table :organizations do
      drop_column :name
      drop_column :display_name
    end
  end

  down do
    alter_table :organizations do
      add_column :name, String, null: false
      add_column :display_name, String, null: false
    end
  end
end
