FactoryGirl.define do
  factory :idp_sso_descriptor, parent: :sso_descriptor,
                               class: 'IDPSSODescriptor' do

    want_authn_requests_signed false

    after(:create) do |idp|
      idp.add_single_sign_on_service(create :single_sign_on_service,
                                            idp_sso_descriptor: idp)
    end

    trait :with_ui_info do
      after(:create) do |idp|
        idp.ui_info = create :mdui_ui_info, :with_content, role_descriptor: idp
      end
    end
  end
end
