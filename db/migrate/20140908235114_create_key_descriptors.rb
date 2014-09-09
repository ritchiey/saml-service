Sequel.migration do
  change do

    create_table :key_descriptors do
      primary_key :id
      foreign_key :key_type_id, :key_types,
                  foreign_key_constraint_name: 'key_type_id_fkey'
      foreign_key :key_info_id, :key_infos,
                  foreign_key_constraint_name: 'key_info_id_fkey'

      TrueClass :disabled

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
