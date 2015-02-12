FactoryGirl.define do
  factory :tag do
    name { Faker::Name.name }
    entity_descriptor :entity_descriptor
    role_descriptor :role_descriptor
  end
end
