FactoryGirl.define do
  factory :saml_uri do
    uri 'urn:oasis:names:tc:SAML:2.0:protocol'
    type :protocol_support

    factory :attribute_name_saml_uri do
      uri 'urn:oasis:names:tc:SAML:2.0:attrname-format:uri'
      type :attribute_name_format
    end

    factory :name_id_format_saml_uri do
      uri 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
      type :name_identifier_format
    end
  end
end
