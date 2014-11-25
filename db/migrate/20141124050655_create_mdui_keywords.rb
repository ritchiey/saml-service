Sequel.migration do
  change do

    create_table :keywords do
      primary_key :id
      String :lang
      Text :content

      foreign_key :ui_info_id, :ui_infos, null: true,
                  foreign_key_constraint_name: 'key_ui_info_fkey'
    end

  end
end
