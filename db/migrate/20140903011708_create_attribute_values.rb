Sequel.migration do
  change do

    create_table :attribute_values do
      primary_key :id
      foreign_key :attribute_id, :attributes, null: false,
                  foreign_key_constraint_name: 'attribute_av_fkey'

      String :value

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
