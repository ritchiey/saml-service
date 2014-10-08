Sequel.migration do
  change do

    create_table :saml_uris do
      primary_key :id
      String :uri, null: false, text: true
      Integer :type, null: false

      String :description

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
