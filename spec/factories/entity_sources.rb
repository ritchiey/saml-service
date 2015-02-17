FactoryGirl.define do
  factory :entity_source do
    active true
    rank { (Time.now.to_f * 1000).to_i }
  end
end
