FactoryGirl.define do
  factory :sp_sso_descriptor, parent: :sso_descriptor,
                              class: 'SPSSODescriptor' do
    authn_requests_signed false
    want_assertions_signed false

    after(:create) do |sp|
      sp.add_assertion_consumer_service(create :assertion_consumer_service,
                                               sp_sso_descriptor: sp)
    end

    trait :request_attributes do
      after(:create) do |sp|
        sp.add_attribute_consuming_service(create :attribute_consuming_service)
      end
    end
  end
end
