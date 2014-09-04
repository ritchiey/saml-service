Sequel.migration do
  change do
    alter_table :attribute_values do
      add_foreign_key :attribute_id, :attributes,
                      foreign_key_constraint_name: 'attributes_id_fkey'
    end
  end
end
