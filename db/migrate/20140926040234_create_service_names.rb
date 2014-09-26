Sequel.migration do
  change do

    create_table :service_names do
      primary_key :id
      foreign_key :attribute_consuming_service_id, :attribute_consuming_services,
                  null: false, foreign_key_constraint_name: 'acs_sn_ln_fkey'
    end

  end
end
