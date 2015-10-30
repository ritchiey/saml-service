require 'rails_helper'

describe RoleDescriptor do
  it_behaves_like 'a basic model'
  it_behaves_like 'a taggable model', :role_descriptor_tag, :role_descriptor

  context 'validations' do
    it { is_expected.to validate_presence :entity_descriptor }
    it { is_expected.to have_many_to_one :entity_descriptor }
    it { is_expected.to validate_presence :enabled }

    context 'instance validations' do
      subject { create :role_descriptor }
      it { is_expected.to validate_presence :protocol_supports }
    end
  end

  context 'optional attributes' do
    it { is_expected.to have_many_to_one :organization }
    it { is_expected.to have_one_to_many :key_descriptors }
    it { is_expected.to have_one_to_many :contact_people }
    it { is_expected.to have_one_to_many :scopes }
    it { is_expected.to have_column :extensions, type: :text }

    it { is_expected.to have_one_to_one :ui_info }
  end

  describe '#extensions?' do
    context 'with extensions' do
      subject { create :role_descriptor, :with_extensions }
      it 'is true' do
        expect(subject.extensions?).to be_truthy
      end
    end
    context 'without extensions or ui_info' do
      it 'is false' do
        expect(subject.extensions?).to be_falsey
      end
    end
    context 'with ui_info' do
      subject { create :role_descriptor, :with_ui_info }
      it 'is true' do
        expect(subject.extensions?).to be_truthy
      end
    end
    context 'with scope' do
      subject { create :role_descriptor, :with_scope }
      it 'is true' do
        expect(subject.extensions?).to be_truthy
      end
    end
    context 'with scope, ui_info and extensions' do
      subject do
        create :role_descriptor, :with_ui_info, :with_extensions, :with_scope
      end
      it 'is true' do
        expect(subject.extensions?).to be_truthy
      end
    end
  end

  describe '#key_descriptors?' do
    context 'with key descriptors' do
      subject { create :role_descriptor, :with_key_descriptors }
      it 'is true' do
        expect(subject.key_descriptors?).to be_truthy
      end
    end
    context 'without key descriptors' do
      it 'is false' do
        expect(subject.key_descriptors?).to be_falsey
      end
    end
  end

  describe '#contact_people?' do
    context 'with contacts' do
      subject { create :role_descriptor, :with_contacts }
      it 'is true' do
        expect(subject.contact_people?).to be_truthy
      end
    end
    context 'without contacts' do
      it 'is false' do
        expect(subject.contact_people?).to be_falsey
      end
    end
  end

  describe '#scopes?' do
    context 'with scope' do
      subject { create :role_descriptor, :with_scope }
      it 'is true' do
        expect(subject.scopes?).to be_truthy
      end
    end
    context 'without scope' do
      it 'is false' do
        expect(subject.scopes?).to be_falsey
      end
    end
  end

  describe '#functioning?' do
    context 'when RoleDescriptor is valid' do
      subject { create :role_descriptor }

      before { subject.enabled = true }

      it 'valid' do
        expect(subject).to be_valid
      end
      it 'is functioning when enabled' do
        expect(subject).to be_functioning
      end
      it 'is not functioning when not enabled' do
        subject.enabled = false
        expect(subject).not_to be_functioning
      end
    end

    context 'when RoleDescriptor is invalid' do
      subject { create :role_descriptor }

      before do
        subject.enabled = true
        subject.entity_descriptor = nil
      end

      it 'is not valid' do
        expect(subject).not_to be_valid
      end
      it 'is not functioning when enabled' do
        expect(subject).not_to be_functioning
      end
      it 'is not functioning when not enabled' do
        subject.enabled = false
        expect(subject).not_to be_functioning
      end
    end
  end
end
