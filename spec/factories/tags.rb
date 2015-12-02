FactoryGirl.define do
  factory :tag do
    name { Faker::Lorem.word }
    association :known_entity
  end

  factory :known_entity_tag, class: 'Tag' do
    name { Faker::Lorem.word }
    association :known_entity
  end
end
