FactoryGirl.define do
  factory :known_entity do
    transient { hostname { "e.#{Faker::Internet.domain_name}" } }

    association :entity_source

    entity_id { "https://#{hostname}/shibboleth" }
    active true
  end
end
