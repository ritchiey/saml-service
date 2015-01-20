require 'rails_helper'

describe RoleDescriptor do
  it_behaves_like 'a basic model'

  context 'validations' do
    it { is_expected.to validate_presence :entity_descriptor }
    it { is_expected.to have_many_to_one :entity_descriptor }
    it { is_expected.to validate_presence :active }

    context 'instance validations' do
      subject { create :role_descriptor }
      it { is_expected.to validate_presence :protocol_supports }
    end
  end

  context 'optional attributes' do
    it { is_expected.to have_many_to_one :organization }
    it { is_expected.to have_one_to_many :key_descriptors }
    it { is_expected.to have_one_to_many :contact_people }
    it { is_expected.to have_column :extensions, type: :text }

    it { is_expected.to have_one_to_one :ui_info }
  end

  describe '#extensions?' do
    context 'with extensions' do
      subject { create :role_descriptor, :with_extensions }
      it 'is true' do
        expect(subject.extensions?).to be
      end
    end
    context 'without extensions' do
      it 'is false' do
        expect(subject.extensions?).not_to be
      end
    end
  end

  describe '#key_descriptors?' do
    context 'with key descriptors' do
      subject { create :role_descriptor, :with_key_descriptors }
      it 'is true' do
        expect(subject.key_descriptors?).to be
      end
    end
    context 'without key descriptors' do
      it 'is false' do
        expect(subject.key_descriptors?).not_to be
      end
    end
  end

  describe '#contact_people?' do
    context 'with contacts' do
      subject { create :role_descriptor, :with_contacts }
      it 'is true' do
        expect(subject.contact_people?).to be
      end
    end
    context 'without contacts' do
      it 'is false' do
        expect(subject.contact_people?).not_to be
      end
    end
  end
end
