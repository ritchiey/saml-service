FactoryGirl.define do
  factory :attribute_authority_descriptor,
          parent: :role_descriptor, class: 'AttributeAuthorityDescriptor' do
    after :create do |aad|
      aad.add_attribute_service create :attribute_service,
                                       attribute_authority_descriptor: aad
    end
  end
end
