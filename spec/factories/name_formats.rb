FactoryGirl.define do
  factory :name_format do
    uri 'urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified'
    association :attribute
  end
end
