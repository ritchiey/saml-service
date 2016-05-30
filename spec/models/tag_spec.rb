# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Tag, type: :model do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :name }
  it { is_expected.to have_many_to_one :known_entity }

  let(:role_descriptor) { create(:role_descriptor) }
  let(:known_entity) { create(:known_entity) }

  let(:tag_name) { Faker::Lorem.word }

  context 'with no owner' do
    let(:tag) { build(:tag, known_entity: nil) }
    subject { tag }
    it { is_expected.to_not be_valid }
    context 'the error message' do
      before { tag.valid? }
      subject { tag.errors }
      it 'is expected to be a single owner validation' do
        expect(subject).to eq(known_entity: ['is not present'])
      end
    end
  end

  context '[name, known_entity] uniqueness' do
    before do
      create(:known_entity_tag,
             known_entity: known_entity, name: tag_name)
    end

    let(:tag) do
      build(:known_entity_tag,
            known_entity: known_entity, name: tag_name)
    end

    subject { tag }
    before { tag.valid? }
    it { is_expected.to_not be_valid }

    context 'the error message' do
      subject { tag.errors }
      it 'is expected to be a uniqueness validation' do
        expect(subject)
          .to eq([:name, :known_entity] => ['is already taken'])
      end
    end
  end
end
