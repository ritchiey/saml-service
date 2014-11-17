Sequel.migration do
  change do

    create_table :ui_infos do
      primary_key :id
      foreign_key :role_descriptor_id, :role_descriptors, null: false,
                  foreign_key_constraint_name: 'mdui_ui_rd_fkey'
    end

  end
end
