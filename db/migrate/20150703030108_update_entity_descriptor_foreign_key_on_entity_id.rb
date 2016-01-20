Sequel.migration do
  up do
    alter_table :entity_ids do
      set_column_allow_null(:entity_descriptor_id)
    end
  end

  down do
    alter_table :entity_ids do
      set_column_not_allow_null(:entity_descriptor_id)
    end
  end
end
