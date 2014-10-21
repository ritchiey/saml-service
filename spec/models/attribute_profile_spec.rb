require 'rails_helper'

RSpec.describe AttributeProfile, type: :model do
  context 'Extends SamlURI' do
    it { is_expected.to have_many_to_one :idp_sso_descriptor }
    it { is_expected.to have_many_to_one :attribute_authority_descriptor }

    let(:subject) { FactoryGirl.create :attribute_profile }
    context 'ownership' do
      it 'must be owned' do
        expect(subject.valid?).to be false
      end

      it 'owned by idp_sso_descriptor' do
        subject.idp_sso_descriptor = FactoryGirl.create :idp_sso_descriptor
        expect(subject.valid?).to be true
      end

      it 'owned by attribute_authority_descriptor' do
        subject.attribute_authority_descriptor =
        FactoryGirl.create :attribute_authority_descriptor

        expect(subject.valid?).to be true
      end

      it 'cant have multiple owners' do
        subject.idp_sso_descriptor = FactoryGirl.create :idp_sso_descriptor
        subject.attribute_authority_descriptor =
        FactoryGirl.create :attribute_authority_descriptor

        expect(subject.valid?).to be false
      end
    end
  end
end
