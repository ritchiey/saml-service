require 'rails_helper'

describe MetadataInstance do
  it_behaves_like 'a basic model'

  it { is_expected.to have_one_to_many :entity_descriptors }
  it { is_expected.to have_one_to_many :ca_key_infos }
  it { is_expected.to validate_presence :name }
  it { is_expected.not_to validate_presence :publication_info }
  it { is_expected.to validate_presence :hash_algorithm }
  it { is_expected.to validate_includes(%w(sha1 sha256), :hash_algorithm) }

  context 'optional attributes' do
    it { is_expected.to have_one_to_one :registration_info }
    it { is_expected.to have_one_to_one :entity_attribute }

    it { is_expected.to have_column :extensions, type: :text }
  end

  context 'ca_verify_depth' do
    subject { create :metadata_instance }

    it 'is expected to be present if ca_key_infos is populated' do
      subject.add_ca_key_info create :ca_key_info
      expect(subject).to validate_presence :ca_verify_depth
    end
    it 'is not expected to be present if ca_key_infos is empty' do
      subject.ca_key_infos.clear
      expect(subject).not_to validate_presence :ca_verify_depth
    end
  end

  context 'when saved' do
    subject { create(:metadata_instance) }
    it { is_expected.to validate_presence :publication_info }
  end

  context 'PublicationInfo' do
    subject { create(:metadata_instance).publication_info }

    it { is_expected.to be_valid }

    it 'has a publisher' do
      expect(subject.publisher).not_to be_nil
    end
  end
end
