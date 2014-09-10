Sequel.migration do
  change do

    create_table :contacts do
      primary_key :id
      String :given_name
      String :surname
      String :email_address
      String :telephone_number
      String :company

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
