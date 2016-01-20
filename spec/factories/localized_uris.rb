FactoryGirl.define do
  factory :localized_uri do
    uri { Faker::Internet.url }
    lang 'en'
  end
end
