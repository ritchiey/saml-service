FactoryGirl.define do
  factory :contact do
    given_name { Faker::Name.first_name }
    surname { Faker::Name.last_name }
    email_address { Faker::Internet.email }
    telephone_number { Faker::PhoneNumber.phone_number }
    company { Faker::Company.name }
  end
end
