require 'rails_helper'

RSpec.describe RawEntityDescriptor do
  it_behaves_like 'a basic model'

  it { is_expected.to have_many_to_one(:known_entity) }
  it { is_expected.to validate_presence :entity_id }

  it { is_expected.to validate_presence(:xml) }
  it { is_expected.to validate_max_length(65_535, :xml) }
  it { is_expected.to validate_presence(:known_entity) }
  it { is_expected.to validate_unique(:known_entity) }

  context 'xml validation' do
    subject { build(:raw_entity_descriptor) }

    it 'accepts a valid EntityDescriptor payload' do
      expect(subject).to be_valid
    end

    it 'rejects an EntitiesDescriptor payload' do
      subject.xml =
        '<EntitiesDescriptor xmlns="urn:oasis:names:tc:SAML:2.0:metadata">' \
        "\n#{subject.xml}\n</EntitiesDescriptor>"

      expect(subject).not_to be_valid
      expect(subject.errors[:xml])
        .to contain_exactly('must have <EntityDescriptor> as the root')
    end

    it 'rejects an EntityDescriptor payload with no namespace' do
      subject.xml = subject.xml.sub(/xmlns=".*"/, '')

      expect(subject).not_to be_valid
      expect(subject.errors[:xml])
        .to include(match(/must have SAML 2\.0 metadata namespace/))
    end

    it 'rejects a schema-invalid EntityDescriptor' do
      subject.xml =
        '<EntityDescriptor xmlns="urn:oasis:names:tc:SAML:2.0:metadata"/>'

      expect(subject).not_to be_valid
      expect(subject.errors[:xml])
        .to contain_exactly(match(/is not valid per the XML Schema/))
    end
  end

  describe '#functioning?' do
    subject { create :raw_entity_descriptor }

    context 'when ED is valid' do
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
      before do
        subject.enabled = true
        subject.xml = nil
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

  describe '#destroy' do
    subject { create :raw_entity_descriptor }

    it 'is successfully destroyed' do
      expect { subject.destroy }.not_to raise_error
    end
  end
end
