FactoryGirl.define do
  factory :role_descriptor do
    entity_descriptor
    active true

    after :create do |rd|
      rd.add_protocol_support(create :protocol_support, role_descriptor: rd)
      rd.add_key_descriptor(create :key_descriptor, role_descriptor: rd)
    end
  end
end
