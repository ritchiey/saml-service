FactoryGirl.define do
  factory :entity_id do
    uri { "#{Faker::Internet.url}/shibboleth" }

    association :entity_descriptor
  end
end
