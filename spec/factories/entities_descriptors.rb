FactoryGirl.define do
  factory :entities_descriptor do
    identifier { Faker::Internet.domain_name }
    name { Faker::Lorem.sentence }

    trait :with_publication_info do
      after(:create) do | ed |
        ed.publication_info = create :mdrpi_publication_info, :with_usage_policy
      end
    end

    trait :with_registration_info do
      after(:create) do | ed |
        ed.registration_info = create :mdrpi_registration_info, :with_policy
      end
    end
  end
end
