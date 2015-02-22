require 'rails_helper'

RSpec.describe Tag, type: :model do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :name }
  it { is_expected.to have_many_to_one :entity_descriptor }
  it { is_expected.to have_many_to_one :role_descriptor }

  let(:role_descriptor) { create(:role_descriptor) }
  let(:entity_descriptor) { create(:entity_descriptor) }

  let(:tag_name) { Faker::Lorem.word }

  context 'with no owner' do
    let(:tag) { build(:tag, entity_descriptor: nil, role_descriptor: nil) }
    subject { tag }
    it { is_expected.to_not be_valid }
    context 'the error message' do
      before { tag.valid? }
      subject { tag.errors }
      it 'is expected to be a single owner validation' do
        expect(subject).to eq(ownership: ['Must be owned by one of' \
                                      ' entity_descriptor, role_descriptor'])
      end
    end
  end

  context 'with one owner' do
    subject do
      build(:tag, role_descriptor: role_descriptor,
                  entity_descriptor: nil)
    end
    it { is_expected.to be_valid }
  end

  context 'with more than one owner' do
    let(:tag) do
      build(:tag, role_descriptor: role_descriptor,
                  entity_descriptor: entity_descriptor)
    end
    subject { tag }
    it { is_expected.to_not be_valid }
    context 'the error message' do
      before { tag.valid? }
      subject { tag.errors }
      it 'is expected to be a single owner validation' do
        expect(subject).to eq(ownership: ['Cannot be owned by more than one' \
                                      ' of entity_descriptor, role_descriptor'])
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

    context 'entity_descriptor tag with same name' do
      subject do
        build(:entity_descriptor_tag,
              entity_descriptor: entity_descriptor, name: tag_name)
      end
      before { tag.valid? }
      it { is_expected.to be_valid }
    end
  end

  context '[name, entity_descriptor] uniqueness' do
    before do
      create(:entity_descriptor_tag,
             entity_descriptor: entity_descriptor, name: tag_name)
    end

    let(:tag) do
      build(:entity_descriptor_tag,
            entity_descriptor: entity_descriptor, name: tag_name)
    end

    subject { tag }
    before { tag.valid? }
    it { is_expected.to_not be_valid }

    context 'the error message' do
      subject { tag.errors }
      it 'is expected to be a uniqueness validation' do
        expect(subject)
          .to eq([:name, :entity_descriptor] => ['is already taken'])
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
