Sequel.migration do
  change do
    create_table :known_entities do
      primary_key :id
      String :entity_id, null: false
      TrueClass :active, null: false

      foreign_key :entity_source_id, null: false,
                  foreign_key_constraint_name: 'entity_source_id_fk'

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end
