Sequel.migration do
  change do
    alter_table :localized_names do
       set_column_type :value, 'varchar(2048)'
    end
  end
end
                        
