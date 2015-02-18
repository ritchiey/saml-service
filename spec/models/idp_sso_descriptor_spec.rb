require 'rails_helper'

describe IDPSSODescriptor do
  it_behaves_like 'a tagged model'

  context 'extends sso_descriptor' do
    it { is_expected.to have_many_to_one :entity_descriptor }
    it { is_expected.to have_one_to_many :single_sign_on_services }

    context 'optional attributes' do
      it { is_expected.to have_one_to_many :name_id_mapping_services }
      it { is_expected.to have_one_to_many :assertion_id_request_services }
      it { is_expected.to have_one_to_many :attribute_profiles }
      it { is_expected.to have_one_to_many :attributes }
    end

    context 'validations' do
      it { is_expected.to validate_presence :entity_descriptor }
      it { is_expected.to validate_presence :want_authn_requests_signed }

      context 'instance validations' do
        let(:subject) { create :idp_sso_descriptor }
        it 'has at least 1 single sign on service' do
          expect(subject).to validate_presence :single_sign_on_services
        end
      end
    end

    describe '#name_id_mapping_services?' do
      context 'when populated' do
        subject { create(:idp_sso_descriptor, :with_name_id_mapping_services) }
        it 'is true' do
          expect(subject.name_id_mapping_services?).to be
        end
      end
      context 'when unpopulated' do
        subject { create :idp_sso_descriptor }
        it 'is false' do
          expect(subject.name_id_mapping_services?).not_to be
        end
      end
    end

    describe '#assertion_id_request_services?' do
      context 'when populated' do
        subject do
          create(:idp_sso_descriptor, :with_assertion_id_request_services)
        end
        it 'is true' do
          expect(subject.assertion_id_request_services?).to be
        end
      end
      context 'when unpopulated' do
        subject { create :idp_sso_descriptor }
        it 'is false' do
          expect(subject.assertion_id_request_services?).not_to be
        end
      end
    end

    describe '#attribute_profiles?' do
      context 'when populated' do
        subject do
          create(:idp_sso_descriptor, :with_attribute_profiles)
        end
        it 'is true' do
          expect(subject.attribute_profiles?).to be
        end
      end
      context 'when unpopulated' do
        subject { create :idp_sso_descriptor }
        it 'is false' do
          expect(subject.attribute_profiles?).not_to be
        end
      end
    end

    describe '#attributes?' do
      context 'when populated' do
        subject do
          create(:idp_sso_descriptor, :with_attributes)
        end
        it 'is true' do
          expect(subject.attributes?).to be
        end
      end
      context 'when unpopulated' do
        subject { create :idp_sso_descriptor }
        it 'is false' do
          expect(subject.attributes?).not_to be
        end
      end
    end

    describe '#disco_hints?' do
      context 'when populated' do
        subject do
          create(:idp_sso_descriptor, :with_disco_hints)
        end
        it 'is true' do
          expect(subject.disco_hints?).to be
        end
      end
      context 'when unpopulated' do
        subject { create :idp_sso_descriptor }
        it 'is false' do
          expect(subject.disco_hints?).not_to be
        end
      end
    end
  end
end
