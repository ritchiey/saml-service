Sequel.migration do
  change do

    create_table :subjects do
      primary_key :id
      String :targeted_id
      String :shared_token

      String :name
      String :mail

      FalseClass :enabled
      FalseClass :complete

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
