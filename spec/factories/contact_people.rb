FactoryGirl.define do
  factory :contact_person do
    contact_type :technical
    association :contact
  end
end
