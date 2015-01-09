Sequel.migration do
  change do
    alter_table :entities_descriptors do
      add_column :ca_verify_depth, Integer
    end
  end
end
