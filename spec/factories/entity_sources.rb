# frozen_string_literal: true
FactoryGirl.define do
  factory :entity_source do
    enabled true
    rank { (Time.now.to_f * 100).to_i }
    source_tag { Faker::Lorem.words.join('-') }

    trait :external do
      url { "https://#{Faker::Internet.domain_name}/federation/metadata.xml" }
    end
  end
end
