Sequel.migration do
  change do

    create_table :protocol_supports do
      primary_key :id
      foreign_key :role_descriptor_id, :role_descriptors,
                  null: false, foreign_key_constraint_name: 'ps_rd_fkey'
    end

  end
end
