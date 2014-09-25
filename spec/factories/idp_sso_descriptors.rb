FactoryGirl.define do
  factory :idp_sso_descriptor, parent: :sso_descriptor,
                               class: 'IDPSSODescriptor' do

    want_authn_requests_signed false

    after(:create) do |idp|
      idp.add_single_sign_on_service(create :single_sign_on_service,
                                            idp_sso_descriptor: idp)
    end
  end
end
