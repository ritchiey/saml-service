Sequel.migration do
  change do

    create_table :service_descriptions do
      primary_key :id
      foreign_key :attribute_consuming_service_id, :attribute_consuming_services,
                  null: false, foreign_key_constraint_name: 'acs_sd_ln_fkey'
    end

  end
end
