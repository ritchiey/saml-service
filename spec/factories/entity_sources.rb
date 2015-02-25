FactoryGirl.define do
  factory :entity_source do
    active true
    rank { (Time.now.to_f * 1000).to_i }
    url { "https://#{Faker::Internet.domain_name}/federation/metadata.xml" }
  end
end
