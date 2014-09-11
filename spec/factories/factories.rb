FactoryGirl.define do
  to_create(&:save)

  trait :with_organization do
    association :organization
  end

  # Used with EntityDescriptors, RoleDescriptors etc
  trait :with_key_descriptor do
    after(:create) do |descriptor|
      descriptor.add_key_descriptor(create :key_descriptor)
    end
  end

  trait :with_contact_person do
    after(:create) do |descriptor|
      descriptor.add_contact_person(create :contact_person)
    end
  end
end
