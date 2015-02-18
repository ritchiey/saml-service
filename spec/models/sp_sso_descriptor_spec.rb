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

  describe '#with_any_tag' do
    let(:tag_name) { Faker::Lorem.word }
    let(:sp_sso_descriptor) { create(:sp_sso_descriptor) }

    subject { SPSSODescriptor.with_any_tag(tag_name) }

    context 'with no existing tags' do
      it { is_expected.to eq([]) }
    end

    context 'with an existing associated sp sso descriptor tag' do
      before do
        create(:role_descriptor_tag, role_descriptor: sp_sso_descriptor,
                                     name: tag_name)
      end
      it { is_expected.to contain_exactly(sp_sso_descriptor) }
      it { is_expected.to contain_exactly(an_instance_of(SPSSODescriptor)) }
    end

    context 'with multiple sp sso descriptors existing for a tag' do
      let!(:another_sp_sso_descriptor) { create(:sp_sso_descriptor) }

      before do
        create(:role_descriptor_tag, role_descriptor: sp_sso_descriptor,
                                     name: tag_name)
        create(:role_descriptor_tag, role_descriptor:
                                         another_sp_sso_descriptor,
                                     name: tag_name)
      end
      it do
        is_expected.to contain_exactly(sp_sso_descriptor,
                                       another_sp_sso_descriptor)
      end
      it do
        is_expected.to contain_exactly(an_instance_of(SPSSODescriptor),
                                       an_instance_of(SPSSODescriptor))
      end
    end

    context 'with multiple tags existing for a sp sso descriptor' do
      let(:another_tag_name) { Faker::Lorem.word }

      subject { SPSSODescriptor.with_any_tag([tag_name, another_tag_name]) }

      before do
        create(:role_descriptor_tag, role_descriptor: sp_sso_descriptor,
                                     name: tag_name)
        create(:role_descriptor_tag, role_descriptor: sp_sso_descriptor,
                                     name: another_tag_name)
      end

      it { is_expected.to contain_exactly(sp_sso_descriptor) }
      it { is_expected.to contain_exactly(an_instance_of(SPSSODescriptor)) }
    end

    context 'with multiple unrelated sp sso descriptor tags already existing' do
      let(:another_tag_name) { Faker::Lorem.word }
      let(:role_descriptor) { create(:role_descriptor) }

      subject { SPSSODescriptor.with_any_tag([tag_name, another_tag_name]) }

      before do
        create(:role_descriptor_tag, name: tag_name)
        create(:role_descriptor_tag, name: another_tag_name)
      end

      it { is_expected.to eq([]) }
    end
  end
end
