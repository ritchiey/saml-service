Sequel.migration do
  change do
    alter_table :federation_registry_objects do
      rename_column :object_type, :internal_class_name
      rename_column :object_id, :internal_id
    end
  end
end
