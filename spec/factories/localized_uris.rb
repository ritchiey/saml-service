FactoryGirl.define do
  factory :localized_uri do
    value { Faker::Internet.url }
    lang 'en'
  end
end
