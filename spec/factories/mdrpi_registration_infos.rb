FactoryGirl.define do
  factory :mdrpi_registration_info, class: 'MDRPI::RegistrationInfo' do
    registration_authority { Faker::Internet.url }
  end
end
