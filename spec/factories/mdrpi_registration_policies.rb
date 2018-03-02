# frozen_string_literal: true

FactoryBot.define do
  factory :mdrpi_registration_policy, class: 'MDRPI::RegistrationPolicy',
                                      parent: :localized_uri do
    registration_info factory: :mdrpi_registration_info
  end
end
