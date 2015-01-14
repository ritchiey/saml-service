FactoryGirl.define do
  factory :entities_descriptor do
    name { Faker::Internet.domain_name }

    after :create do | ed |
      ed.publication_info = create :mdrpi_publication_info,
                                   entities_descriptor: ed
    end

    trait :with_registration_info do
      after :create do | ed |
        ed.registration_info = create :mdrpi_registration_info, :with_policy
      end
    end
  end
end
