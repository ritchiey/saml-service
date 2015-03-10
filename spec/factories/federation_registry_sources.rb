FactoryGirl.define do
  factory :federation_registry_source do
    association :entity_source

    hostname { "manager.#{Faker::Internet.domain_name}" }
    secret { SecureRandom.urlsafe_base64 }
  end
end
