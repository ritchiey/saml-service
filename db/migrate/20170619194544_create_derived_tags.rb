Sequel.migration do
  change do
    create_table :derived_tags do
      primary_key :id

      Integer :rank, null: false

      String :tag_name, null: false
      String :when_tags, null: false
      String :unless_tags, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      TrueClass :enabled, null: false

      index [:rank, :enabled]
    end
  end
end
