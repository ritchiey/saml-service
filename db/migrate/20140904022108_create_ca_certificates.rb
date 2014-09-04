Sequel.migration do
  change do

    create_table :ca_certificates do
      primary_key :id
      String :data, text: true, null: false

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
