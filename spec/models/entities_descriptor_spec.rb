require 'rails_helper'

describe EntitiesDescriptor do
  it_behaves_like 'a basic model'

  it { is_expected.to have_many_to_one :parent_entities_descriptor }
  it { is_expected.to have_one_to_many :entities_descriptors }
  it { is_expected.to have_one_to_many :entity_descriptors }
  it { is_expected.to have_one_to_many :ca_key_infos }
  it { is_expected.to validate_presence :name }

  context 'optional attributes' do
    it { is_expected.to have_one_to_one :registration_info }
    it { is_expected.to have_one_to_one :entity_attribute }

    it { is_expected.to have_column :extensions, type: :text }
  end

  context 'ca_verify_depth' do
    subject { create :entities_descriptor }

    it 'is expected to be present if ca_key_infos is populated' do
      subject.add_ca_key_info create :ca_key_info
      expect(subject).to validate_presence :ca_verify_depth
    end
    it 'is not expected to be present if ca_key_infos is empty' do
      subject.ca_key_infos.clear
      expect(subject).not_to validate_presence :ca_verify_depth
    end
  end

  context 'publication_info' do
    subject { create :entities_descriptor }

    context 'as parent/singular entities_descriptor' do
      it 'validates publication_info is present' do
        expect(subject).to validate_presence :publication_info
      end
    end
    context 'as child entities_descriptor' do
      before do
        subject.parent_entities_descriptor = create :entities_descriptor
      end
      it 'does not validate publication_info is present' do
        expect(subject).not_to validate_presence :publication_info
      end
    end
  end

  context '#ca_keys?' do
    subject { create :entities_descriptor }

    it 'is true if ca_key_infos is populated' do
      subject.add_ca_key_info(create :ca_key_info)
      expect(subject.ca_keys?).to be
    end
    it 'is false if ca_key_infos is empty' do
      subject.ca_key_infos.clear
      expect(subject.ca_keys?).not_to be
    end
  end

  context '#publication_info?' do
    subject { create :entities_descriptor }

    it 'is true if publication_info is populated' do
      expect(subject.publication_info?).to be
    end
    it 'is false if publication_info is empty' do
      subject.publication_info = nil
      expect(subject.publication_info?).not_to be
    end
  end

  context '#sibling?' do
    subject { create :entities_descriptor }

    it 'is true if parent_entities_descriptor is populated' do
      subject.parent_entities_descriptor = create :entities_descriptor
      expect(subject.sibling?).to be
    end
    it 'is false if parent_entities_descriptor is not populated' do
      expect(subject.sibling?).not_to be
    end
  end
end
