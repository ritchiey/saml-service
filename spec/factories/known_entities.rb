FactoryGirl.define do
  factory :known_entity do
    association :entity_source

    entity_id { "https://e.#{Faker::Internet.domain_name}/shibboleth" }
    active true
  end
end
