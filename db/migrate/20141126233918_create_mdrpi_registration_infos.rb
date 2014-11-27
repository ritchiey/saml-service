Sequel.migration do
  change do

    create_table :registration_infos do
      primary_key :id
      foreign_key :entities_descriptor_id, :entities_descriptors, null: true,
            foreign_key_constraint_name: 'ri_entitiesdesc_fkey'
      foreign_key :entity_descriptor_id, :entity_descriptors, null: true,
            foreign_key_constraint_name: 'ri_entdesc_fkey'

      String :registration_authority, null: false
      DateTime :registration_instant

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
