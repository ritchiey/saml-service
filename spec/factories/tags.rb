FactoryGirl.define do
  factory :tag do
    name { Faker::Name.name }
    association :entity_descriptor
    association :role_descriptor
  end
end
