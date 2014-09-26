FactoryGirl.define do
  factory :attribute_consuming_service do
    index { Faker::Number.number 2 }
    default false

    after(:create) do |acs|
      acs.add_service_name create :service_name,
                                  attribute_consuming_service: acs
      acs.add_requested_attribute create :requested_attribute,
                                         attribute_consuming_service: acs
    end
    association :sp_sso_descriptor
  end
end
