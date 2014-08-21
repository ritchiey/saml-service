FactoryGirl.define do
  factory :indexed_endpoint do
    is_default false
    index 1

    to_create { |i| i.save }
  end
end
