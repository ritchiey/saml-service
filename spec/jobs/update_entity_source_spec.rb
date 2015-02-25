require 'rails_helper'

RSpec.describe UpdateEntitySource do
  subject { create(:entity_source) }
  before { stub_request(:get, subject.url).to_return(response) }
  let(:response) { { status: 200, headers: {}, body: xml } }
  let(:doc) { Nokogiri::XML.parse(xml) }

  let(:entity_ids) do
    doc.xpath('//*[local-name() = "EntityDescriptor"]/@entityID').map(&:value)
  end

  def swallow
    yield
  rescue => e
    @exception = e
  end

  def run
    described_class.perform(id: subject.id)
  end

  def entity_descriptors(entities:)
    fragments = (1..entities).map do
      attributes_for(:raw_entity_descriptor)[:xml]
      .gsub('xmlns="urn:oasis:names:tc:SAML:2.0:metadata"', '')
      .strip
    end
    fragments.join("\n")
  end

  def entities_descriptor(fore: nil, entities:)
    [
      '<EntitiesDescriptor xmlns="urn:oasis:names:tc:SAML:2.0:metadata">',
      fore,
      entity_descriptors(entities: entities).indent(2),
      '</EntitiesDescriptor>'
    ].compact.join("\n")
  end

  context 'with a single entity' do
    let(:xml) { entities_descriptor(entities: 1) }

    let(:entity_id) { entity_ids.first }

    it 'creates the known entity' do
      expect { run }.to change { subject.known_entities(true).count }.by(1)
    end

    it 'creates the raw entity descriptor' do
      expect { run }.to change(RawEntityDescriptor, :count).by(1)
    end

    it 'uses the correct entity id' do
      run
      expect(subject.known_entities.last.entity_id).to eq(entity_id)
    end

    it 'sets the raw entity descriptor as active' do
      run
      expect(subject.known_entities.last).to be_active
    end

    it 'sets the xml for the raw entity descriptor' do
      run
      expect(subject.known_entities.last.raw_entity_descriptor.xml)
        .to eq(Nokogiri::XML.parse(xml).root.elements[0].canonicalize)
    end

    context 'when the entity already exists' do
      let!(:entity) do
        KnownEntity.create(entity_source: subject, active: true,
                           entity_id: entity_id)
      end

      it 'uses the existing entity' do
        expect { run }.not_to change(KnownEntity, :count)
      end

      it 'creates the raw entity descriptor' do
        expect { run }.to change(RawEntityDescriptor, :count).by(1)
      end

      context 'when the raw entity descriptor already exists' do
        let!(:red) do
          RawEntityDescriptor.create(xml: old_xml, known_entity: entity)
        end
        let(:hostname) { URI.parse(entity.entity_id).hostname }

        let(:old_xml) do
          <<-EOF.strip_heredoc
            <EntityDescriptor xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
                entityID="https://#{hostname}/idp/shibboleth">
              <AttributeAuthorityDescriptor
                  protocolSupportEnumeration="nope">
                <AttributeService
                    Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP"
                    Location="https://#{hostname}/invalid"/>
              </AttributeAuthorityDescriptor>
            </EntityDescriptor>
          EOF
        end

        it 'uses the existing entity' do
          expect { run }.not_to change(KnownEntity, :count)
        end

        it 'uses the existing raw entity descriptor' do
          expect { run }.not_to change(RawEntityDescriptor, :count)
        end

        it 'updates the raw entity descriptor' do
          new_xml = Nokogiri::XML.parse(xml).root.elements[0].canonicalize
          expect { run }.to change { red.reload.xml }.from(old_xml).to(new_xml)
        end
      end
    end
  end

  context 'with multiple entities' do
    let(:xml) { entities_descriptor(entities: 3) }

    it 'creates the raw entity descriptors' do
      expect { run }.to change { subject.known_entities(true).count }.by(3)
        .and change(RawEntityDescriptor, :count).by(3)
    end

    it 'uses the correct entity id' do
      run
      expect(subject.known_entities.map(&:entity_id))
        .to contain_exactly(*entity_ids)
    end

    it 'sets the raw entity descriptors as active' do
      run
      expect(subject.known_entities).to all(be_active)
    end

    it 'sets the xml for the raw entity descriptors' do
      run

      subject.known_entities.each do |entity|
        e = doc.xpath('//*[local-name() = "EntityDescriptor" and ' \
                      "@entityID='#{entity.entity_id}']").first
        expect(entity.raw_entity_descriptor.xml).to eq(e.canonicalize)
      end
    end
  end

  context 'with invalid xml' do
    let(:xml) do
      entities_descriptor(entities: 1)
        .gsub(/entityID="[^"]+"/, '')
    end

    it 'creates no records' do
      expect { swallow { run } }
        .not_to change { KnownEntity.count + RawEntityDescriptor.count }
    end

    it 'raises an informative exception' do
      swallow { run }
      expect(@exception.message)
        .to match(/Unable to update EntitySource/)
        .and match(subject.url)
        .and match(/Schema validation errors prevented processing/)
        .and match(/Element.*EntityDescriptor.*entityID.*is required/)
    end
  end

  context 'with unsupported Extensions' do
    let(:ext) do
      '<se:SomeExtension xmlns:se="https://example.com/test/some-extension">' \
        '<se:TestElement>Content!</se:TestElement>' \
        '</se:SomeExtension>'
    end

    let(:xml) do
      entities_descriptor(fore: "<Extensions>#{ext}</Extensions>", entities: 1)
    end

    it 'creates the entity record' do
      expect { run }.to change { subject.known_entities(true).count }.by(1)
        .and change(RawEntityDescriptor, :count).by(1)
    end
  end

  context 'with a http error' do
    let(:response) { { status: [471, 'Test Error'], headers: {}, body: '' } }

    it 'raises an informative message' do
      swallow { run }
      expect(@exception.message)
        .to match('Unable to update EntitySource')
        .and match(subject.url)
        .and match('471 Test Error')
    end
  end
end
