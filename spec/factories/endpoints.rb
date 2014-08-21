FactoryGirl.define do
  factory :endpoint do
    location 'https://example.org'

    to_create { |i| i.save }
  end
end
