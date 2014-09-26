require 'rails_helper'

describe SPSSODescriptor do
  context 'extends sso_descriptor' do
    it { is_expected.to validate_presence :authn_requests_signed }
    it { is_expected.to validate_presence :want_assertions_signed }
    it { is_expected.to have_one_to_many :attribute_consuming_services }

    let(:subject) { FactoryGirl.create :sp_sso_descriptor }
    it 'has at least 1 assertion consumer service' do
      expect(subject).to validate_presence :assertion_consumer_services
    end
  end
end
