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
    it { is_expected.to have_one_to_one :publication_info }
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

  context '#publication_info' do
    subject { create :entities_descriptor }

    it 'is true if publication_info is populated' do
      subject.publication_info = create :mdrpi_publication_info
      expect(subject.publication_info?).to be
    end
    it 'is false if ca_key_infos is empty' do
      subject.publication_info = nil
      expect(subject.publication_info?).not_to be
    end
  end
end
