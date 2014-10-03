FactoryGirl.define do
  factory :attribute_profile do
    uri 'urn:oasis:names:tc:SAML:2.0:profiles:attribute:basic'
    association :idp_sso_descriptor
  end
end
