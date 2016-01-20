Sequel.migration do
  change do

    create_table :encryption_methods do
      primary_key :id
      String :algorithm, null: false
      String :key_size
      String :oae_params

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
