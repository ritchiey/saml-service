Sequel.migration do
  change do
    create_table :keypairs do
      primary_key :id
      String :certificate, null: false, size: 4096
      String :key, null: false, size: 4096
    end
  end
end
