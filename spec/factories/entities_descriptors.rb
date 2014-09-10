FactoryGirl.define do
  factory :entities_descriptor do
    identifier { Faker::Internet.domain_name }
    name { Faker::Lorem.sentence }
  end
end
