Sequel.migration do
  change do

    create_table :publication_infos do
      primary_key :id
      foreign_key :entities_descriptor_id, :entities_descriptors, null: true,
            foreign_key_constraint_name: 'pi_entitiesdesc_fkey'
      foreign_key :entity_descriptor_id, :entity_descriptors, null: true,
            foreign_key_constraint_name: 'pi_entdesc_fkey'

      String :publisher

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
