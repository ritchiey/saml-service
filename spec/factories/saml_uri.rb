# frozen_string_literal: true

FactoryBot.define do
  factory :saml_uri do
    uri { "#{Faker::Internet.url}/shibboleth" }
    description { Faker::Lorem.sentence }
  end
end
