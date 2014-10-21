FactoryGirl.define do
  trait :endpoint do
    location { Faker::Internet.url 'example.com' }
  end

  trait :response_location do
    response_location { Faker::Internet.url 'example.com' }
  end

  trait :indexed_endpoint do
    endpoint
    is_default false
    index { Faker::Base.numerify '#' }
  end

  trait :default_indexed_endpoint do
    indexed_endpoint
    is_default true
  end

  factory :_endpoint, class: 'Endpoint', traits: [:endpoint]
  factory :assertion_id_request_service, traits: [:endpoint]
  factory :authz_service, traits: [:endpoint]
  factory :manage_name_id_service, traits: [:endpoint]
  factory :name_id_mapping_service, traits: [:endpoint]
  factory :single_logout_service, traits: [:endpoint]
  factory :single_sign_on_service, traits: [:endpoint]

  factory :_indexed_endpoint, class: 'IndexedEndpoint',
                              traits: [:indexed_endpoint]
  factory :artifact_resolution_service, traits: [:indexed_endpoint]
  factory :assertion_consumer_service, traits: [:indexed_endpoint]
  factory :discovery_response_service, traits: [:indexed_endpoint]

  factory :attribute_service do
    endpoint
    association :attribute_authority_descriptor
  end
end
