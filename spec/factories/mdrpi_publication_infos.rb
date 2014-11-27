FactoryGirl.define do
  factory :mdrpi_publication_info, class: 'MDRPI::PublicationInfo' do
    publisher { Faker::Internet.url }

    trait :with_usage_policy do
      after(:create) do | pi |
        pi.add_usage_policy create :mdrpi_usage_policy
      end
    end
  end
end
