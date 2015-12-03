FactoryGirl.define do
  factory :known_entity do
    transient { hostname { "e.#{Faker::Internet.domain_name}" } }

    association :entity_source
    enabled true

    trait :with_idp do
      after(:create) do |ke|
        idp = create :idp_sso_descriptor
        ke.entity_descriptor = idp.entity_descriptor
      end
    end

    trait :with_raw_entity_descriptor do
      after(:create) do |ke|
        red = create :raw_entity_descriptor, known_entity: ke
        ke.entity_descriptor = red
      end
    end
  end
end
