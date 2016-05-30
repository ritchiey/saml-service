# frozen_string_literal: true
FactoryGirl.define do
  factory :tag do
    sequence :name do |n|
      "#{Faker::Lorem.word}-#{n}"
    end
    association :known_entity
  end

  factory :known_entity_tag, class: 'Tag' do
    name { Faker::Lorem.word }
    association :known_entity
  end
end
