Sequel.migration do
  change do
    add_index :metadata_instances, :primary_tag, unique: true
  end
end
