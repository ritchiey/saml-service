Sequel.migration do
  change do

    create_table :attributes do
      primary_key :id
      foreign_key :attribute_base_id, :attribute_bases, null: false,
                  foreign_key_constraint_name: 'attribute_base_id_fkey'

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
