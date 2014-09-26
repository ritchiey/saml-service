Sequel.migration do
  change do

    create_table :sp_sso_descriptors do
      primary_key :id
      TrueClass :authn_requests_signed, null: false
      TrueClass :want_assertions_signed, null: false
    end

  end
end
