require 'rails_helper'

RSpec.describe RawEntityDescriptor do
  it_behaves_like 'a basic model'

  it { is_expected.to have_many_to_one(:known_entity) }

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
end
