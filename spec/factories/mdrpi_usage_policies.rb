FactoryGirl.define do
  factory :mdrpi_usage_policy, class: 'MDRPI::UsagePolicy',
                               parent: :localized_uri do
    publication_info factory: :mdrpi_publication_info
  end

end
