FactoryGirl.define do
  factory :tag do
    name { Faker::Name.name }
    association :entity_descriptor
  end
end
