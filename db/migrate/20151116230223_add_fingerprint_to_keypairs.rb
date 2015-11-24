Sequel.migration do
  change do
    add_column :keypairs, :fingerprint, String, size: 40
    add_index :keypairs, :fingerprint, unique: true
  end
end
