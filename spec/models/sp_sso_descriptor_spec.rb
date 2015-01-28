require 'rails_helper'

describe SPSSODescriptor do
  context 'extends sso_descriptor' do
    it { is_expected.to validate_presence :entity_descriptor }
    it { is_expected.to have_many_to_one :entity_descriptor }

    it { is_expected.to validate_presence :authn_requests_signed }
    it { is_expected.to validate_presence :want_assertions_signed }
    it { is_expected.to have_one_to_many :attribute_consuming_services }

    let(:subject) { create :sp_sso_descriptor }
    it 'has at least 1 assertion consumer service' do
      expect(subject).to validate_presence :assertion_consumer_services
    end
    it 'is invalid without assertion consumer services' do
      subject.assertion_consumer_services.clear
      expect(subject).not_to be_valid
    end
    it 'can store attribute consumer services' do
      expect(subject).to have_one_to_many :attribute_consuming_services
    end

    describe '#attribute_consuming_services?' do
      context 'when populated' do
        subject do
          create(:sp_sso_descriptor, :with_attribute_consuming_services)
        end
        it 'is true' do
          expect(subject.attribute_consuming_services?).to be
        end
      end
      context 'when unpopulated' do
        subject { create :sp_sso_descriptor }
        it 'is false' do
          expect(subject.attribute_consuming_services?).not_to be
        end
      end
    end
  end
end
