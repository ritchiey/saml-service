FactoryGirl.define do
  factory :entity_id do
    uri { "#{Faker::Internet.url}/shibboleth" }

    association :entity_descriptor

    factory :raw_entity_id do
      uri { "#{Faker::Internet.url}/shibboleth" }
      association :raw_entity_descriptor
    end
  end
end
