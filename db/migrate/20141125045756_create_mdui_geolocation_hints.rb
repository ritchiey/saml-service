Sequel.migration do
  change do

    create_table :geolocation_hints do
      primary_key :id
      foreign_key :disco_hints_id, :disco_hints, null: true,
            foreign_key_constraint_name: 'geo_disco_hints_fkey'

      String :uri, null: false

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
