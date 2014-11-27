FactoryGirl.define do
  factory :mdrpi_registration_info, class: 'MDRPI::RegistrationInfo' do
    registration_authority { Faker::Internet.url }

    trait :with_policy do
      registration_instant { Faker::Date.backward(100) }
      after(:create) do | ri |
        ri.add_registration_policy create :mdrpi_registration_policy
      end
    end
  end
end
