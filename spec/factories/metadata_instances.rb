FactoryGirl.define do
  factory :metadata_instance do
    name { Faker::Internet.domain_name }
    hash_algorithm 'sha256'

    after :create do | mi |
      create(:mdrpi_publication_info, metadata_instance: mi)
      mi.reload
    end

    trait :with_registration_info do
      after :create do | mi |
        mi.registration_info = create :mdrpi_registration_info
      end
    end
  end
end
