FactoryGirl.define do
  factory :attribute_value do
    value { Faker::Lorem.word }

    association :attribute, factory: :attribute
  end
end
