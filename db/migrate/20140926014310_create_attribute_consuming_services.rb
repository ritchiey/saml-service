Sequel.migration do
  change do

    create_table :attribute_consuming_services do
      primary_key :id
      foreign_key :sp_sso_descriptor_id, :sp_sso_descriptors, null: false,
                  foreign_key_constraint_name: 'sp_attrcs_fkey'

      Integer :index, null: false
      TrueClass :default, null: false

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
