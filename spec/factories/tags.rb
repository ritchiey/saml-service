FactoryGirl.define do
  factory :tag do
    name { Faker::Lorem.word }
    association :entity_descriptor
  end

  factory :ed_tag, class: 'Tag' do
    name { Faker::Lorem.word }
    association :entity_descriptor
  end

  factory :rd_tag, class: 'Tag' do
    name { Faker::Lorem.word }
    association :role_descriptor
  end
end
