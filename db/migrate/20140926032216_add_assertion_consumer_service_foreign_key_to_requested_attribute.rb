Sequel.migration do
  change do
    alter_table :requested_attributes do
      add_foreign_key :attribute_consuming_service_id,
                      :attribute_consuming_services, null: false,
                      foreign_key_constraint_name: 'attrcs_ra_fkey'
    end
  end
end
