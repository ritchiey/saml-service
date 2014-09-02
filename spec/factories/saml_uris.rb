FactoryGirl.define do
  factory :saml_uri do
    uri 'urn:oasis:names:tc:SAML:2.0:protocol'
    type :protocol_support

    to_create { |i| i.save }

    factory :attribute_name_saml_uri do
      uri 'urn:oasis:names:tc:SAML:2.0:attrname-format:uri'
      type :attribute_name_format
    end
  end
end
