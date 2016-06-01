# frozen_string_literal: true
require 'rails_helper'
require 'digest/sha1'

RSpec.describe EntityId, type: :model do
  context 'extends saml uri' do
    it { is_expected.to have_many_to_one :entity_descriptor }
    it { is_expected.to have_many_to_one :raw_entity_descriptor }

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
        expect(subject.sha1).to eq(Digest::SHA1.hexdigest(subject.uri))
      end
    end

    context 'ownership' do
      subject { create :entity_id, entity_descriptor: nil }

      it 'must be owned' do
        expect(subject).not_to be_valid
      end

      it 'can be owned by entity_descriptor' do
        subject.entity_descriptor = create :entity_descriptor
        expect(subject).to be_valid
      end

      it 'can be owned by raw_entity_descriptor' do
        subject.raw_entity_descriptor = create :raw_entity_descriptor

        expect(subject).to be_valid
      end

      it 'cant have multiple owners' do
        subject.entity_descriptor = create :entity_descriptor
        subject.raw_entity_descriptor = create :raw_entity_descriptor

        expect(subject).not_to be_valid
      end
    end

    context 'uri' do
      let(:entity_id) { build(:entity_id, uri: uri) }
      before { entity_id.valid? }
      subject { entity_id }

      context 'valid url' do
        let(:uri) { Faker::Internet.url }
        it { is_expected.to be_valid }
      end

      context 'valid uri' do
        let(:scheme) { Faker::Lorem.word }
        let(:namespace) { Faker::Internet.domain_word }
        let(:uri_parts) { (1..10).to_a.sample }
        let(:uri) { Array.new(uri_parts) { Faker::Lorem.word }.join(':') }
        it { is_expected.to be_valid }
      end

      context 'as characters' do
        let(:uri) { Faker::Lorem.characters }
        it { is_expected.to_not be_valid }
        context 'the errors' do
          subject { entity_id.errors }
          it { is_expected.to eq(uri: ['is not a valid uri']) }
        end
      end
    end
  end

  describe '#parent' do
    it 'provides owning EntityDescriptor' do
      subject { create :entity_id }
      expect(subject.parent).to eq(subject.entity_descriptor)
    end

    it 'provides owning RawEntityDescriptor' do
      subject { create :raw_entity_id }
      expect(subject.parent).to eq(subject.raw_entity_descriptor)
    end
  end
end
