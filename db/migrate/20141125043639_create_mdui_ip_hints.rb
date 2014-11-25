Sequel.migration do
  change do

    create_table :ip_hints do
      primary_key :id
      foreign_key :disco_hints_id, :disco_hints, null: true,
            foreign_key_constraint_name: 'ip_disco_hints_fkey'

      String :block

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
