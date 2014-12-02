Sequel.migration do
  change do

    create_table :entity_attributes do
      primary_key :id
      foreign_key :entities_descriptor_id, :entities_descriptors, null: true,
            foreign_key_constraint_name: 'ea_entitiesdesc_fkey'
      foreign_key :entity_descriptor_id, :entity_descriptors, null: true,
            foreign_key_constraint_name: 'ea_entdesc_fkey'


      DateTime :created_at
      DateTime :updated_at
    end

  end
end
