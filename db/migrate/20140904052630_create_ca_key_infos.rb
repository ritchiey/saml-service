Sequel.migration do
  change do

    create_table :ca_key_infos do
      primary_key :id

      String :data, text: true, null: false
      String :key_name
      DateTime :expiry

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
