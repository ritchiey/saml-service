Sequel.migration do
  change do

    create_table :key_infos do
      primary_key :id
      String :data, text: true, null: false
      String :subject
      String :issuer
      String :key_name

      DateTime :expiry
      DateTime :created_at
      DateTime :updated_at
    end

  end
end
