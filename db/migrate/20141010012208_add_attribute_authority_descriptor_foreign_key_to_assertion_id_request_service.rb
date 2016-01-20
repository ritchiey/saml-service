Sequel.migration do
  change do
    alter_table :assertion_id_request_services do
      add_foreign_key :attribute_authority_descriptor_id,
                      :attribute_authority_descriptors, null: true,
                      foreign_key_constraint_name: 'aad_aidrs_fkey'
    end
  end
end
