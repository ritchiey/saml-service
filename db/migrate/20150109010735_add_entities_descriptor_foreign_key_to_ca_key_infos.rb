Sequel.migration do
  change do
    alter_table :ca_key_infos do
      add_foreign_key :entities_descriptor_id, :entities_descriptors,
                      null: false,
                      foreign_key_constraint_name: 'enities_des_caki_fkey'
    end
  end
end
