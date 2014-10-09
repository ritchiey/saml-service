FactoryGirl.define do
  factory :key_descriptor do
    key_type :signing
    disabled false
    association :key_info
  end
end
