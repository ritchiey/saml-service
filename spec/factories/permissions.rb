# frozen_string_literal: true

FactoryBot.define do
  factory :permission do
    association :role
    value { "#{Faker::Lorem.word}:#{Faker::Lorem.word}" }
  end
end
