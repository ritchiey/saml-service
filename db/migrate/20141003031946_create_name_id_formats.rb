Sequel.migration do
  change do

    create_table :name_id_formats do
      primary_key :id
      foreign_key :sso_descriptor_id, :sso_descriptors,
                  null: true, foreign_key_constraint_name: 'nidf_sso_fkey'
    end

  end
end
