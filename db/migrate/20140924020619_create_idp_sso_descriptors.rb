Sequel.migration do
  change do

    create_table :idp_sso_descriptors do
      primary_key :id
      TrueClass :want_authn_requests_signed, null: false
    end

  end
end
