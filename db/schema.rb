Sequel.migration do
  change do
    create_table(:additional_metadata_locations) do
      primary_key :id, :type=>"int(11)"
      column :uri, "varchar(255)"
      column :namespace, "varchar(255)"
      column :created_at, "datetime"
      column :updated_at, "datetime"
    end
    
    create_table(:artifact_resolution_services) do
      primary_key :id, :type=>"int(11)"
    end
    
    create_table(:assertion_consumer_services) do
      primary_key :id, :type=>"int(11)"
    end
    
    create_table(:assertion_id_request_services) do
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
    
    create_table(:key_types) do
      primary_key :id, :type=>"int(11)"
      column :use, "int(11)", :null=>false
      column :created_at, "datetime"
      column :updated_at, "datetime"
    end
    
    create_table(:manage_name_id_services) do
      primary_key :id, :type=>"int(11)"
    end
    
    create_table(:name_id_mapping_services) do
      primary_key :id, :type=>"int(11)"
    end
    
    create_table(:requested_attributes) do
      primary_key :id, :type=>"int(11)"
      column :reasoning, "varchar(255)", :null=>false
      column :required, "tinyint(1)", :null=>false
      column :approved, "tinyint(1)"
      column :created_at, "datetime"
      column :updated_at, "datetime"
    end
    
    create_table(:saml_uris) do
      primary_key :id, :type=>"int(11)"
      column :uri, "varchar(255)", :null=>false
      column :type, "int(11)", :null=>false
      column :description, "varchar(255)"
      column :created_at, "datetime"
      column :updated_at, "datetime"
    end
    
    create_table(:schema_migrations) do
      column :filename, "varchar(255)", :null=>false
      
      primary_key [:filename]
    end
    
    create_table(:single_logout_services) do
      primary_key :id, :type=>"int(11)"
    end
    
    create_table(:single_sign_on_services) do
      primary_key :id, :type=>"int(11)"
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
    
    create_table(:attributes) do
      primary_key :id, :type=>"int(11)"
      foreign_key :attribute_base_id, :attribute_bases, :type=>"int(11)", :null=>false, :key=>[:id]
      column :created_at, "datetime"
      column :updated_at, "datetime"
      
      index [:attribute_base_id], :name=>:attribute_base_id_fkey
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
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140908222924_create_key_types.rb')"
  end
end
