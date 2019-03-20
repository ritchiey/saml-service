Sequel.migration do
  up do
    alter_table :localized_names do
       set_column_type :value, 'varchar(2048)'
    end
  end

  down do
    alter_table :localized_names do
       set_column_type :value, 'varchar(255)'
    end
  end
end
                        
