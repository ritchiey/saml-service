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

  context 'publication info' do
    subject { create :entity_descriptor }
    let(:local_publication_info) do
      build :mdrpi_publication_info
    end

    context '#locate_publication_info' do
      it 'returns local publication_info if present' do
        subject.publication_info = local_publication_info
        expect(subject.locate_publication_info).to eq(local_publication_info)
      end
      it 'returns parent entities_descriptor publication_info if not present' do
        expect(subject.locate_publication_info).to be
          .and eq(subject.entities_descriptor.publication_info)
      end
    end
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

  describe '#with_tag' do
    let(:tag_name) { Faker::Lorem.word }
    let(:ed) { create(:entity_descriptor) }

    subject { EntityDescriptor.with_tag(tag_name) }

    context 'with no tags' do
      it { is_expected.to eq([]) }
    end

    context 'with an existing associated tag' do
      before { create(:ed_tag, entity_descriptor: ed, name: tag_name) }
      it { is_expected.to contain_exactly(ed) }
    end

    context 'with multiple entity descriptors for a tag' do
      let!(:another_ed) { create(:entity_descriptor) }

      before do
        create(:ed_tag, entity_descriptor: ed, name: tag_name)
        create(:ed_tag, entity_descriptor: another_ed, name: tag_name)
      end
      it { is_expected.to contain_exactly(ed, another_ed) }
    end

    context 'with multiple tags for an entity descriptor' do
      let(:another_tag_name) { Faker::Lorem.word }

      subject { EntityDescriptor.with_tag([tag_name, another_tag_name]) }

      before do
        create(:ed_tag, entity_descriptor: ed, name: tag_name)
        create(:ed_tag, entity_descriptor: ed, name: another_tag_name)
      end

      it { is_expected.to contain_exactly(ed) }
    end
  end
end
