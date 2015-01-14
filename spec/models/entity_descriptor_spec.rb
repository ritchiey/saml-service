require 'rails_helper'

describe EntityDescriptor do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :entities_descriptor }
  it { is_expected.to validate_presence :entity_id }
  it { is_expected.to validate_presence :role_descriptors }

  context 'at least one of' do
    it { is_expected.to have_one_to_many :role_descriptors }
    it { is_expected.to have_one_to_many :idp_sso_descriptors }
    it { is_expected.to have_one_to_many :sp_sso_descriptors }
    it { is_expected.to have_one_to_many :attribute_authority_descriptors }
  end

  context 'optional attributes' do
    it { is_expected.to have_many_to_one :organization }
    it { is_expected.to have_one_to_many :contact_people }
    it { is_expected.to have_one_to_many :additional_metadata_locations }
    it { is_expected.to have_column :extensions, type: :text }

    it { is_expected.to have_one_to_one :registration_info }
    it { is_expected.to have_one_to_one :publication_info }
    it { is_expected.to have_one_to_one :entity_attribute }
  end

  context 'validation' do
    subject { create :entity_descriptor }

    it 'invalid without organization' do
      subject.organization = nil
      expect(subject).not_to be_valid
    end
    it 'invalid when no descriptors' do
      expect(subject).not_to be_valid
    end
    it 'valid with role_descriptor' do
      subject.add_role_descriptor create :role_descriptor
      expect(subject).to be_valid
    end
    it 'valid with idp_sso_descriptor' do
      subject.add_role_descriptor create :idp_sso_descriptor
      expect(subject).to be_valid
    end
    it 'valid with attribute_authority_descriptor' do
      subject.add_role_descriptor create :attribute_authority_descriptor
      expect(subject).to be_valid
    end
    it 'valid with sp_sso_descriptor' do
      subject.add_role_descriptor create :sp_sso_descriptor
      expect(subject).to be_valid
    end
  end
end
