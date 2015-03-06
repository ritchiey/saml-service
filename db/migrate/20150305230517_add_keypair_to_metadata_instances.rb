Sequel.migration do
  change do
    alter_table :metadata_instances do
      add_foreign_key :keypair_id, :keypairs, null: false
    end
  end
end
