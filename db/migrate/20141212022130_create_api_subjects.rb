Sequel.migration do
  change do

    create_table :api_subjects do
      primary_key :id
      String :x509_cn, null: false
      String :description, null: false
      String :contact_name, null: false
      String :contact_mail, null: false

      FalseClass :enabled

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
