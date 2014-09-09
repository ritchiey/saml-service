FactoryGirl.define do
  factory :attribute_value do
    value { Faker::Lorem.word }
    approved true

    association :attribute, factory: :attribute

    factory :unapproved_attribute_value do
      approved false
    end
  end
end
