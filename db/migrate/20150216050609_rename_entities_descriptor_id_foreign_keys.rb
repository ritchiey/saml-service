Sequel.migration do
  change do
    table_fkeys = {
      ca_key_infos: 'enities_des_caki_fkey',
      entity_attributes: 'ea_entitiesdesc_fkey',
      publication_infos: 'pi_entitiesdesc_fkey',
      registration_infos: 'ri_entitiesdesc_fkey'
    }

    table_fkeys.each do |table, fkey|
      alter_table table do
        drop_foreign_key :entities_descriptor_id, name: fkey
        add_foreign_key :metadata_instance_id, :metadata_instances,
                        foreign_key_constraint_name: "#{table}_mi_id_fk"
      end
    end

    alter_table :entity_descriptors do
      drop_foreign_key :entities_descriptor_id,
                       name: 'entities_descriptors_id_key'
      add_foreign_key :known_entity_id, :known_entities, null: false,
                      foreign_key_constraint_name: 'known_entity_id_key'
    end
  end
end
