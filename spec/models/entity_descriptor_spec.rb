require 'rails_helper'

describe EntityDescriptor do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :known_entity }
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

    context 'with a valid descriptor' do
      before { subject.add_role_descriptor create :role_descriptor }

      it 'is invalid without organization' do
        subject.organization = nil
        expect(subject).not_to be_valid
      end
      it 'is invalid without contacts' do
        subject.contact_people.first.delete
        expect(subject).not_to be_valid
      end
      it 'is invalid without a technical contact' do
        subject.contact_people.first.delete
        subject.add_contact_person(create :contact_person,
                                          contact_type: :support)
        expect(subject).not_to be_valid
      end
      context 'only a technical contact' do
        before { subject.add_role_descriptor create :role_descriptor }
        it { is_expected.to be_valid }
        it 'has one contact person' do
          expect(subject.contact_people.size).to eq(1)
        end
        it 'has a technical contact person' do
          expect(subject.contact_people.first.contact_type).to eq(:technical)
        end
      end
      context 'multiple contacts' do
        before do
          subject.add_contact_person(create :contact_person,
                                            contact_type: :support)
        end
        it { is_expected.to be_valid }
        it 'has two contact people' do
          expect(subject.contact_people.size).to eq(2)
        end
        it 'has a technical contact person' do
          expect(subject.contact_people.first.contact_type).to eq(:technical)
        end
        it 'has a support contact person' do
          expect(subject.contact_people.last.contact_type).to eq(:support)
        end
      end
      context '#entity_attribute?' do
        it 'is true when an entity_attribute is set' do
          subject.entity_attribute = create :mdattr_entity_attribute
          expect(subject.entity_attribute?).to be
        end
        it 'is false when an entity_attribute is not set' do
          expect(subject.entity_attribute?).not_to be
        end
      end
    end

    it 'is invalid when no descriptors' do
      expect(subject).not_to be_valid
    end
    it 'is valid with role_descriptor' do
      subject.add_role_descriptor create :role_descriptor
      expect(subject).to be_valid
    end
    it 'is valid with idp_sso_descriptor' do
      subject.add_role_descriptor create :idp_sso_descriptor
      expect(subject).to be_valid
    end
    it 'is valid with attribute_authority_descriptor' do
      subject.add_role_descriptor create :attribute_authority_descriptor
      expect(subject).to be_valid
    end
    it 'is valid with sp_sso_descriptor' do
      subject.add_role_descriptor create :sp_sso_descriptor
      expect(subject).to be_valid
    end
  end

  describe '#functioning?' do
    context 'when ED is valid' do
      let(:idp) { create :idp_sso_descriptor }
      subject { idp.entity_descriptor }

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

    context 'when ED is invalid' do
      subject { create :entity_descriptor }

      before do
        subject.enabled = true
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

  describe '#touch' do
    let(:role_descriptor) { create :role_descriptor }
    subject { role_descriptor.entity_descriptor }

    it 'modifies parent EntityDescriptor on save' do
      Timecop.travel(30.seconds) do
        expect { subject.touch }.to change { subject.updated_at }
      end
    end
  end
end
