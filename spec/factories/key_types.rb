FactoryGirl.define do
  factory :key_type do
    use :signing

    to_create { |i| i.save }
  end
end
