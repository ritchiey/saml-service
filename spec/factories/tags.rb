FactoryGirl.define do
  factory :tag do
    name { Faker::Lorem.word }
    association :entity_descriptor
  end

  factory :entity_descriptor_tag, class: 'Tag' do
    name { Faker::Lorem.word }
    association :entity_descriptor
  end

  factory :role_descriptor_tag, class: 'Tag' do
    name { Faker::Lorem.word }
    association :role_descriptor
  end

  factory :entities_descriptor_tag, class: 'Tag' do
    name { Faker::Lorem.word }
    association :entities_descriptor
  end
end
