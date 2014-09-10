FactoryGirl.define do
  trait :with_organization do
    association :organization
  end

  factory :entity_descriptor do
    entity_id { "#{Faker::Internet.url}/shibboleth" }
    association :entities_descriptor
  end
end
