FactoryGirl.define do
  factory :mdattr_entity_attribute, class: 'MDATTR::EntityAttribute' do
    trait :with_attribute do
      after :create do | ea |
        ea.add_attribute create :attribute
      end
    end

    trait :with_refeds_rs_entity_category do
      after :create do | ea |
        ea.add_attribute create(:attribute, :with_value,
                                value: 'http://refeds.org/category/research-and-scholarship',
                                name: 'http://macedir.org/entity-category')
      end
    end
  end
end
