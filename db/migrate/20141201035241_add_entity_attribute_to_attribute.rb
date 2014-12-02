Sequel.migration do
  change do
    alter_table :attributes do
      add_foreign_key :entity_attribute_id, :entity_attributes, null: true,
                      foreign_key_constraint_name: 'ea_attr_fkey'
    end
  end
end
