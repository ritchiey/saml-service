FactoryGirl.define do
  factory :tag do
    name { Faker::Lorem.characters }
    association :entity_descriptor
  end

  factory :entity_descriptor_tag, class: 'Tag' do
    name { Faker::Lorem.characters }
    association :entity_descriptor
  end

  factory :role_descriptor_tag, class: 'Tag' do
    name { Faker::Lorem.characters }
    association :role_descriptor
  end
end
