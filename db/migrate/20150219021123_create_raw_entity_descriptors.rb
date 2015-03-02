Sequel.migration do
  change do
    create_table :raw_entity_descriptors do
      primary_key :id
      Integer :known_entity_id, null: false

      String :xml, text: true, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index :known_entity_id, unique: true
      foreign_key [:known_entity_id], :known_entities,
                  name: 'raw_entity_known_entity_id_fk'
    end
  end
end
