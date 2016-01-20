Sequel.migration do
  up do
    alter_table :raw_entity_descriptors do
      set_column_type :xml, 'mediumtext'
    end
  end

  down do
    alter_table :raw_entity_descriptors do
      set_column_type :xml, 'text'
    end
  end
end
