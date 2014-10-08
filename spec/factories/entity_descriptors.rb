FactoryGirl.define do
  factory :entity_descriptor do
    association :entities_descriptor

    after :create do |ed|
      ed.entity_id = create :entity_id, entity_descriptor: ed
    end

  end
end
