FactoryGirl.define do
  factory :key_descriptor do
    disabled { false }
    key_info

    trait :signing do
      key_type :signing
    end

    trait :encryption do
      key_type :encryption
    end
  end
end
