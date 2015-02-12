require 'rails_helper'

RSpec.describe Tag, type: :model do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :name }
  it { is_expected.to have_many_to_one :entity_descriptor }
  it { is_expected.to have_many_to_one :role_descriptor }

  context 'with no owner' do
    let(:tag) { build(:tag, entity_descriptor: nil, role_descriptor: nil) }
    subject { tag }
    it { is_expected.to_not be_valid }
    context 'the error message' do
      before { tag.valid? }
      subject { tag.errors }
      it do
        is_expected.to eq(ownership: ['Must be owned by one of' \
                                      ' entity_descriptor, role_descriptor'])
      end
    end
  end

  context 'with one owner' do
    subject { build(:tag, role_descriptor: nil) }
    it { is_expected.to be_valid }
  end

  context 'with more than one owner' do
    let(:tag) { build(:tag) }
    subject { tag }
    it { is_expected.to_not be_valid }
    context 'the error message' do
      before { tag.valid? }
      subject { tag.errors }
      it do
        is_expected.to eq(ownership: ['Cannot be owned by more than one of' \
                                      ' entity_descriptor, role_descriptor'])
      end
    end
  end
end
