Sequel.migration do
  up do
    alter_table :organizations do
      drop_column :url
    end
  end

  down do
    alter_table :organizations do
      add_column :url, String, null: true
    end
  end
end
