Sequel.migration do
  change do

    create_table :attribute_bases do
      primary_key :id
      foreign_key :name_format_id, :saml_uris,
                  foreign_key_constraint_name: 'name_format_id_fkey'

      String :name
      String :legacy_name
      String :oid
      String :description

      TrueClass :admin_restricted
      TrueClass :specification_required

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
