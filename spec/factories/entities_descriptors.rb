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

  factory :child_entities_descriptor, class: EntitiesDescriptor do
    name { Faker::Internet.domain_name }
    association :parent_entities_descriptor, factory: :entities_descriptor
  end
end
