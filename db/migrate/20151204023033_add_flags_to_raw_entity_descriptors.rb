Sequel.migration do
  change do

    alter_table :raw_entity_descriptors do
      add_column :idp, TrueClass, default: false
      add_column :sp, TrueClass, default: false
      add_column :standalone_aa, TrueClass, default: false
    end

  end
end
