Sequel.migration do
  change do

    create_table :name_formats do
      primary_key :id
      foreign_key :attribute_id, :attributes,
                  null: true, foreign_key_constraint_name: 'nf_attr_fkey'
    end

  end
end
