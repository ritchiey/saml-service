Sequel.migration do
  change do
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
    
    create_table(:manage_name_id_services) do
      primary_key :id, :type=>"int(11)"
    end
    
    create_table(:name_id_mapping_services) do
      primary_key :id, :type=>"int(11)"
    end
    
    create_table(:saml_uris) do
      primary_key :id, :type=>"int(11)"
      column :uri, "varchar(255)", :null=>false
      column :type, "int(11)", :null=>false
      column :description, "varchar(255)"
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
  end
end
