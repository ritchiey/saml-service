Sequel.migration do
  change do

    create_table :key_types do
      primary_key :id
      Integer :use, null: false

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
