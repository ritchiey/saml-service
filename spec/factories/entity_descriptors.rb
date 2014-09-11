FactoryGirl.define do
  factory :entity_descriptor do
    entity_id { "#{Faker::Internet.url}/shibboleth" }
    association :entities_descriptor
  end
end
