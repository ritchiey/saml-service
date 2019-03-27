Sequel.migration do
  up do
    alter_table :key_infos do
       set_column_type :subject, 'varchar(2048)'
       set_column_type :issuer, 'varchar(2048)'
    end
  end

  down do
    alter_table :key_infos do
       set_column_type :subject, 'varchar(255)'
       set_column_type :issuer, 'varchar(255)'
    end
  end
end
                        
