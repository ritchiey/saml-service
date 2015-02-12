FactoryGirl.define do
  factory :tag do
    name { Faker::Lorem.word }
    association :entity_descriptor
  end
end
