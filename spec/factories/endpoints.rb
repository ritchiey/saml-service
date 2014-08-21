# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  trait :seqel_model do
  end

  factory :endpoint do
    location 'https://example.org'

    to_create { |i| i.save }
    trait :sequel_model
  end
end
