Sequel.migration do
  change do

    create_table :display_names do
      primary_key :id
      foreign_key :ui_info_id, :ui_infos, null: true,
                  foreign_key_constraint_name: 'dn_ui_info_fkey'

    end

  end
end
