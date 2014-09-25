Sequel.migration do
  change do
    create_table(:assertion_consumer_services) do
      primary_key :id, :type=>"int(11)"
    end
    
    create_table(:attribute_services) do
      primary_key :id, :type=>"int(11)"
    end
    
    create_table(:authz_services) do
      primary_key :id, :type=>"int(11)"
    end
    
    create_table(:ca_key_infos) do
      primary_key :id, :type=>"int(11)"
    end
    
    create_table(:contacts) do
      primary_key :id, :type=>"int(11)"
      column :given_name, "varchar(255)"
      column :surname, "varchar(255)"
      column :email_address, "varchar(255)"
      column :telephone_number, "varchar(255)"
      column :company, "varchar(255)"
      column :created_at, "datetime"
      column :updated_at, "datetime"
    end
    
    create_table(:discovery_response_services) do
      primary_key :id, :type=>"int(11)"
    end
    
    create_table(:endpoints) do
      primary_key :id, :type=>"int(11)"
      column :location, "varchar(255)", :null=>false
      column :response_location, "varchar(255)"
      column :created_at, "datetime"
      column :updated_at, "datetime"
    end
    
    create_table(:entities_descriptors) do
      primary_key :id, :type=>"int(11)"
      column :identifier, "varchar(255)", :null=>false
      column :name, "varchar(255)", :null=>false
      column :extensions, "text"
      column :created_at, "datetime"
      column :updated_at, "datetime"
    end
    
    create_table(:idp_sso_descriptors) do
      primary_key :id, :type=>"int(11)"
      column :want_authn_requests_signed, "tinyint(1)", :null=>false
    end
    
    create_table(:indexed_endpoints) do
      primary_key :id, :type=>"int(11)"
      column :is_default, "tinyint(1)", :null=>false
      column :index, "int(11)", :null=>false
    end
    
    create_table(:key_infos) do
      primary_key :id, :type=>"int(11)"
      column :data, "text", :null=>false
      column :subject, "varchar(255)"
      column :issuer, "varchar(255)"
      column :key_name, "varchar(255)"
      column :expiry, "datetime"
      column :created_at, "datetime"
      column :updated_at, "datetime"
    end
    
    create_table(:organizations) do
      primary_key :id, :type=>"int(11)"
      column :name, "varchar(255)", :null=>false
      column :display_name, "varchar(255)", :null=>false
      column :url, "varchar(255)", :null=>false
      column :created_at, "datetime"
      column :updated_at, "datetime"
    end
    
    create_table(:requested_attributes) do
      primary_key :id, :type=>"int(11)"
      column :reasoning, "varchar(255)", :null=>false
      column :required, "tinyint(1)", :null=>false
      column :approved, "tinyint(1)"
      column :created_at, "datetime"
      column :updated_at, "datetime"
    end
    
    create_table(:schema_migrations) do
      column :filename, "varchar(255)", :null=>false
      
      primary_key [:filename]
    end
    
    create_table(:sso_descriptors) do
      primary_key :id, :type=>"int(11)"
    end
    
    create_table(:artifact_resolution_services) do
      primary_key :id, :type=>"int(11)"
      foreign_key :sso_descriptor_id, :sso_descriptors, :type=>"int(11)", :key=>[:id]
      
      index [:sso_descriptor_id], :name=>:sso_ars_fkey
    end
    
    create_table(:assertion_id_request_services) do
      primary_key :id, :type=>"int(11)"
      foreign_key :idp_sso_descriptor_id, :idp_sso_descriptors, :type=>"int(11)", :key=>[:id]
      
      index [:idp_sso_descriptor_id], :name=>:idp_aidr_fkey
    end
    
    create_table(:entity_descriptors) do
      primary_key :id, :type=>"int(11)"
      foreign_key :entities_descriptor_id, :entities_descriptors, :type=>"int(11)", :null=>false, :key=>[:id]
      foreign_key :organization_id, :organizations, :type=>"int(11)", :key=>[:id]
      column :entity_id, "varchar(255)", :null=>false
      column :extensions, "text"
      column :created_at, "datetime"
      column :updated_at, "datetime"
      
      index [:entities_descriptor_id], :name=>:entities_descriptors_id_key
      index [:organization_id], :name=>:organization_id_key
    end
    
    create_table(:manage_name_id_services) do
      primary_key :id, :type=>"int(11)"
      foreign_key :sso_descriptor_id, :sso_descriptors, :type=>"int(11)", :key=>[:id]
      
      index [:sso_descriptor_id], :name=>:sso_mnid_fkey
    end
    
    create_table(:name_id_mapping_services) do
      primary_key :id, :type=>"int(11)"
      foreign_key :idp_sso_descriptor_id, :idp_sso_descriptors, :type=>"int(11)", :key=>[:id]
      
      index [:idp_sso_descriptor_id], :name=>:idp_nidms_fkey
    end
    
    create_table(:single_logout_services) do
      primary_key :id, :type=>"int(11)"
      foreign_key :sso_descriptor_id, :sso_descriptors, :type=>"int(11)", :key=>[:id]
      
      index [:sso_descriptor_id], :name=>:sso_slo_fkey
    end
    
    create_table(:single_sign_on_services) do
      primary_key :id, :type=>"int(11)"
      foreign_key :idp_sso_descriptor_id, :idp_sso_descriptors, :type=>"int(11)", :null=>false, :key=>[:id]
      
      index [:idp_sso_descriptor_id], :name=>:idp_ssos_fkey
    end
    
    create_table(:additional_metadata_locations) do
      primary_key :id, :type=>"int(11)"
      column :uri, "varchar(255)", :null=>false
      column :namespace, "varchar(255)", :null=>false
      column :created_at, "datetime"
      column :updated_at, "datetime"
      foreign_key :entity_descriptor_id, :entity_descriptors, :type=>"int(11)", :null=>false, :key=>[:id]
      
      index [:entity_descriptor_id], :name=>:entity_descriptors_id_key
    end
    
    create_table(:role_descriptors) do
      primary_key :id, :type=>"int(11)"
      foreign_key :entity_descriptor_id, :entity_descriptors, :type=>"int(11)", :null=>false, :key=>[:id]
      foreign_key :organization_id, :organizations, :type=>"int(11)", :key=>[:id]
      column :error_url, "varchar(255)"
      column :active, "tinyint(1)"
      column :extensions, "text"
      column :created_at, "datetime"
      column :updated_at, "datetime"
      
      index [:entity_descriptor_id], :name=>:ed_rd_key
      index [:organization_id], :name=>:o_rd_key
    end
    
    create_table(:contact_people) do
      primary_key :id, :type=>"int(11)"
      foreign_key :contact_id, :contacts, :type=>"int(11)", :null=>false, :key=>[:id]
      column :contact_type_id, "int(11)", :null=>false
      column :extensions, "text"
      column :created_at, "datetime"
      column :updated_at, "datetime"
      foreign_key :entity_descriptor_id, :entity_descriptors, :type=>"int(11)", :key=>[:id]
      foreign_key :role_descriptor_id, :role_descriptors, :type=>"int(11)", :key=>[:id]
      
      index [:contact_id], :name=>:contact_id_fkey
      index [:entity_descriptor_id], :name=>:ed_id_cp_fkey
      index [:role_descriptor_id], :name=>:rd_cp_fkey
    end
    
    create_table(:key_descriptors) do
      primary_key :id, :type=>"int(11)"
      foreign_key :key_info_id, :key_infos, :type=>"int(11)", :key=>[:id]
      column :key_type_id, "int(11)", :null=>false
      column :disabled, "tinyint(1)"
      column :created_at, "datetime"
      column :updated_at, "datetime"
      foreign_key :role_descriptor_id, :role_descriptors, :type=>"int(11)", :key=>[:id]
      
      index [:key_info_id], :name=>:key_info_id_fkey
      index [:role_descriptor_id], :name=>:rd_kd_fkey
    end
    
    create_table(:saml_uris) do
      primary_key :id, :type=>"int(11)"
      column :uri, "varchar(255)", :null=>false
      column :type, "int(11)", :null=>false
      column :description, "varchar(255)"
      column :created_at, "datetime"
      column :updated_at, "datetime"
      foreign_key :role_descriptor_id, :role_descriptors, :type=>"int(11)", :key=>[:id]
      
      index [:role_descriptor_id], :name=>:uri_descriptor_id_fkey
    end
    
    create_table(:attribute_bases) do
      primary_key :id, :type=>"int(11)"
      foreign_key :name_format_id, :saml_uris, :type=>"int(11)", :key=>[:id]
      column :name, "varchar(255)"
      column :legacy_name, "varchar(255)"
      column :oid, "varchar(255)"
      column :description, "varchar(255)"
      column :admin_restricted, "tinyint(1)"
      column :specification_required, "tinyint(1)"
      column :created_at, "datetime"
      column :updated_at, "datetime"
      
      index [:name_format_id], :name=>:name_format_id_fkey
    end
    
    create_table(:encryption_methods) do
      primary_key :id, :type=>"int(11)"
      column :algorithm, "varchar(255)", :null=>false
      column :key_size, "varchar(255)"
      column :oae_params, "varchar(255)"
      column :created_at, "datetime"
      column :updated_at, "datetime"
      foreign_key :key_descriptor_id, :key_descriptors, :type=>"int(11)", :null=>false, :key=>[:id]
      
      index [:key_descriptor_id], :name=>:key_descriptors_enc_fkey
    end
    
    create_table(:attributes) do
      primary_key :id, :type=>"int(11)"
      foreign_key :attribute_base_id, :attribute_bases, :type=>"int(11)", :null=>false, :key=>[:id]
      column :created_at, "datetime"
      column :updated_at, "datetime"
      foreign_key :idp_sso_descriptor_id, :idp_sso_descriptors, :type=>"int(11)", :key=>[:id]
      
      index [:attribute_base_id], :name=>:attribute_base_id_fkey
      index [:idp_sso_descriptor_id], :name=>:idp_attr_fkey
    end
    
    create_table(:attribute_values) do
      primary_key :id, :type=>"int(11)"
      column :value, "varchar(255)"
      column :approved, "tinyint(1)"
      column :created_at, "datetime"
      column :updated_at, "datetime"
      foreign_key :attribute_id, :attributes, :type=>"int(11)", :key=>[:id]
      
      index [:attribute_id], :name=>:attributes_id_fkey
    end
  end
end
Sequel.migration do
  change do
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140818053306_create_endpoints.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140818234240_create_indexed_endpoints.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140822005028_create_assertion_id_request_services.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140822005311_create_attribute_services.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140822005524_create_authz_services.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140822005536_create_manage_name_id_services.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140822005558_create_name_id_mapping_services.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140822005609_create_single_logout_services.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140822005621_create_single_sign_on_services.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140822005638_create_artifact_resolution_services.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140822005656_create_assertion_consumer_services.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140822005711_create_discovery_response_services.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140822031543_create_saml_uris.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140901052651_create_additional_metadata_locations.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140901054038_create_attribute_bases.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140903003601_create_attribute_values.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140903010608_create_attributes.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140903021522_add_attribute_foreign_key_to_attribute_values.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140904004949_create_requested_attributes.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140904052630_create_ca_key_infos.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140908032428_create_key_infos.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140908225337_create_encryption_methods.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140908235114_create_key_descriptors.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140909005102_add_key_descriptor_foreign_key_to_encryption_method.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140910011808_create_contacts.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140910024454_create_contact_people.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140910045450_create_organizations.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140910052947_create_entities_descriptors.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140910054604_create_entity_descriptors.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140910232552_add_entity_descriptor_foreign_key_to_additional_metadata_locations.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140910233606_add_entity_descriptor_foreign_key_to_contact_people.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140911004429_create_role_descriptors.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140911005408_add_role_descriptor_foreign_key_to_key_descriptor.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140911005511_add_role_descriptor_foreign_key_to_contact_person.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140911025005_create_sso_descriptors.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140911025316_add_sso_descriptor_foreign_key_to_artifact_resolution_service.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140911044906_add_sso_descriptor_foreign_key_to_single_logout_service.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140911045122_add_sso_descriptor_foreign_key_to_manage_name_id_service.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140911045706_add_descriptor_foreign_key_to_saml_uri.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140924020619_create_idp_sso_descriptors.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140924021644_add_idp_sso_descriptor_foreign_key_to_single_sign_on_service.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140924041941_add_idp_sso_descriptor_foreign_key_to_name_id_mapping_service.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140924051829_add_idp_sso_descriptor_foreign_key_to_assertion_id_request_service.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140925015857_add_idp_sso_descriptor_foreign_key_to_attribute.rb')"
  end
end
