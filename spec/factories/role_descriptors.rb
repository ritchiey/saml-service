FactoryGirl.define do
  factory :role_descriptor do
    association :entity_descriptor

    error_url { Faker::Internet.url }
    active true
  end
end
