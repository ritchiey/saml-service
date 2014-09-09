FactoryGirl.define do
  factory :key_descriptor do
    disabled false

    association :key_type
    association :key_info
  end
end
