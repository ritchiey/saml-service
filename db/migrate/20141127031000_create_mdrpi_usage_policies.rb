Sequel.migration do
  change do

    create_table :usage_policies do
      primary_key :id
      foreign_key :publication_info_id, :publication_infos, null: false,
            foreign_key_constraint_name: 'up_pi_fkey'
    end

  end
end
