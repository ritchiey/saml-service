FactoryGirl.define do
  factory :role_descriptor do
    association :entity_descriptor

    error_url { Faker::Internet.url }
    active true

    after :create do |rd|
      rd.add_protocol_support(create :protocol_support, role_descriptor: rd)
    end
  end
end
