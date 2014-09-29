FactoryGirl.define do
  factory :organization do
    after(:create) do |org|
      org.add_organization_name create :organization_name, organization: org
      org.add_organization_display_name create :organization_display_name,
                                               organization: org
      org.add_organization_url create :organization_url, organization: org
    end
  end
end
