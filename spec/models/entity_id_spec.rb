require 'rails_helper'
require 'digest/sha1'

RSpec.describe EntityId, type: :model do
  context 'extends saml uri' do
    it { is_expected.to have_many_to_one :entity_descriptor }
    it { is_expected.to validate_presence :entity_descriptor }
    it { is_expected.to validate_presence :sha1 }
    it { is_expected.to validate_max_length 1024, :uri }
  end

  context 'validation' do
    subject { build :entity_id }

    it 'has no sha1 value before validation' do
      expect(subject.sha1).to be_nil
    end

    context 'post validation' do
      before { subject.valid? }

      it 'has sha1 value' do
        expect(subject.sha1).not_to be_nil
      end

      it 'calculates sha1 from uri' do
        expect(subject.sha1).to eq(Digest::SHA1.hexdigest subject.uri)
      end
    end
  end
end
