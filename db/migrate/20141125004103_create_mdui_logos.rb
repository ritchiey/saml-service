Sequel.migration do
  change do

    create_table :logos do
      primary_key :id
      foreign_key :ui_info_id, :ui_infos, null: true,
            foreign_key_constraint_name: 'logo_ui_info_fkey'

      Text :uri, null: false
      String :lang, null: true

      Integer :width
      Integer :height

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
