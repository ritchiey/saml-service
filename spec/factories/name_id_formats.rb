FactoryGirl.define do
  factory :name_id_format do
    uri 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient'
    association :sso_descriptor
  end
end
