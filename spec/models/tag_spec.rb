require 'rails_helper'

RSpec.describe Tag, type: :model do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :name }
  it { is_expected.to have_many_to_one :known_entity }
  it { is_expected.to have_many_to_one :role_descriptor }

  let(:role_descriptor) { create(:role_descriptor) }
  let(:known_entity) { create(:known_entity) }

  let(:tag_name) { Faker::Lorem.word }

  context 'with no owner' do
    let(:tag) { build(:tag, known_entity: nil, role_descriptor: nil) }
    subject { tag }
    it { is_expected.to_not be_valid }
    context 'the error message' do
      before { tag.valid? }
      subject { tag.errors }
      it 'is expected to be a single owner validation' do
        expect(subject).to eq(ownership: ['Must be owned by one of' \
                                      ' known_entity, role_descriptor'])
      end
    end
  end

  context 'with one owner' do
    subject do
      build(:tag, role_descriptor: role_descriptor,
                  known_entity: nil)
    end
    it { is_expected.to be_valid }
  end

  context 'with more than one owner' do
    let(:tag) do
      build(:tag, role_descriptor: role_descriptor,
                  known_entity: known_entity)
    end
    subject { tag }
    it { is_expected.to_not be_valid }
    context 'the error message' do
      before { tag.valid? }
      subject { tag.errors }
      it 'is expected to be a single owner validation' do
        expect(subject).to eq(ownership: ['Cannot be owned by more than one' \
                                      ' of known_entity, role_descriptor'])
      end
    end
  end

  context '[name, role_descriptor] uniqueness' do
    before do
      create(:role_descriptor_tag, role_descriptor:
                                            role_descriptor, name: tag_name)
    end
    let(:tag) do
      build(:role_descriptor_tag, role_descriptor:
                                    role_descriptor, name: tag_name)
    end

    subject { tag }
    before { tag.valid? }
    it { is_expected.to_not be_valid }

    context 'the error message' do
      subject { tag.errors }
      it 'is expected to be a uniqueness validation' do
        expect(subject).to eq([:name, :role_descriptor] => ['is already taken'])
      end
    end

    context 'known_entity tag with same name' do
      subject do
        build(:known_entity_tag,
              known_entity: known_entity, name: tag_name)
      end
      before { tag.valid? }
      it { is_expected.to be_valid }
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

    context 'role_descriptor tag with same name' do
      subject do
        build(:role_descriptor_tag,
              role_descriptor: role_descriptor, name: tag_name)
      end
      before { tag.valid? }
      it { is_expected.to be_valid }
    end
  end
end
