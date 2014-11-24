Sequel.migration do
  change do

    create_table :descriptions do
      primary_key :id
      foreign_key :ui_info_id, :ui_infos, null: true,
                  foreign_key_constraint_name: 'des_ui_info_fkey'
    end

  end
end
