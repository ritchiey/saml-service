# frozen_string_literal: true

FactoryBot.define do
  factory :organization_url, class: 'OrganizationURL',
                             parent: :localized_uri do
    association :organization
  end
end
