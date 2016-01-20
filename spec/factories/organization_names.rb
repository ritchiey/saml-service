FactoryGirl.define do
  factory :organization_name, class: 'OrganizationName',
                              parent: :localized_name do
    association :organization
  end
end
