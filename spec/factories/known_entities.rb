FactoryGirl.define do
  factory :known_entity do
    transient { hostname { "e.#{Faker::Internet.domain_name}" } }

    association :entity_source
    active true

    trait :with_idp do
      after(:create) do |ke|
        idp = create :idp_sso_descriptor
        ke.entity_descriptor = idp.entity_descriptor
      end
    end
  end
end
