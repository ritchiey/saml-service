FactoryGirl.define do
  factory :mdattr_entity_attribute, class: 'MDATTR::EntityAttribute' do
    trait :with_attribute do
      after :create do | ea |
        ea.add_attribute create :attribute
      end
    end
  end
end
