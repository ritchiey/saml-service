Sequel.migration do
  change do

    create_table :api_subjects do
      primary_key :id
      String :x509_dn, null: false

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
