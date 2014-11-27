FactoryGirl.define do
  factory :mdrpi_publication_info, class: 'MDRPI::PublicationInfo' do
    publisher { Faker::Internet.url }
  end
end
