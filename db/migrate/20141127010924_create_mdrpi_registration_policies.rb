Sequel.migration do
  change do

    create_table :registration_policies do
      primary_key :id
      foreign_key :registration_info_id, :registration_infos, null: false,
            foreign_key_constraint_name: 'rp_ri_fkey'
    end

  end
end
