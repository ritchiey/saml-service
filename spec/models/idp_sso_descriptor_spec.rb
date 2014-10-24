require 'rails_helper'

describe IDPSSODescriptor do
  context 'extends sso_descriptor' do
    it { is_expected.to validate_presence :want_authn_requests_signed }
    it { is_expected.to have_one_to_many :single_sign_on_services }

    let(:subject) { create :idp_sso_descriptor }
    it 'has at least 1 single sign on service' do
      expect(subject).to validate_presence :single_sign_on_services
    end

    context 'optional attributes' do
      it { is_expected.to have_one_to_many :name_id_mapping_services }
      it { is_expected.to have_one_to_many :assertion_id_request_services }
      it { is_expected.to have_one_to_many :attribute_profiles }
      it { is_expected.to have_one_to_many :attributes }
    end
  end
end
