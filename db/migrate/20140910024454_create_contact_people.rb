Sequel.migration do
  change do

    create_table :contact_people do
      primary_key :id
      foreign_key :contact_id, :contacts, null: false,
                  foreign_key_constraint_name: 'contact_id_fkey'

      Integer :contact_type_id, null: false
      String :extensions, text: true

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
