FactoryGirl.define do
  factory :organization do
    name { Faker::Company.name }
    display_name { Faker::Company.catch_phrase }
    url { Faker::Internet.url }
  end
end
