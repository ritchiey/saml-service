FactoryGirl.define do
  factory :saml_uri do
    uri 'urn:oasis:names:tc:SAML:2.0:protocol'
    type :protocol_support
  end
end
