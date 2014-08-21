Sequel.migration do
  change do
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
    
    create_table(:schema_migrations) do
      column :filename, "varchar(255)", :null=>false
      
      primary_key [:filename]
    end
  end
end
Sequel.migration do
  change do
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140818053306_create_endpoints.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20140818234240_create_indexed_endpoints.rb')"
  end
end
