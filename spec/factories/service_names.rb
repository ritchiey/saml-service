# frozen_string_literal: true

FactoryBot.define do
  factory :service_name, class: 'ServiceName', parent: :localized_name do
    association :attribute_consuming_service
  end
end
