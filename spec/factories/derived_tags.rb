# frozen_string_literal: true

FactoryGirl.define do
  factory :derived_tag do
    tag_name { Faker::Lorem.word }
    when_tags { Faker::Lorem.words.join(',') }
    unless_tags { Faker::Lorem.words.join(',') }
    sequence :rank
    enabled true
  end
end
