FactoryGirl.define do
  factory :attribute_value do
    value { Faker::Lorem.word }
    approved true

    factory :unapproved_attribute_value do
      approved false
    end
  end
end
