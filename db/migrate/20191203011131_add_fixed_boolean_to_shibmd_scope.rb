Sequel.migration do
  change do
    alter_table :scopes do
      add_column :locked, :boolean, default: false, null: false
    end
  end
end
