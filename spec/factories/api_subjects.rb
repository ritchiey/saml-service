FactoryGirl.define do
  factory :api_subject, class: 'API::APISubject' do
    x509_dn { "cn=#{Faker::Internet.domain_name},o='#{Faker::Company.name}'" }
  end
end
