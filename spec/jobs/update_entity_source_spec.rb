require 'rails_helper'

RSpec.describe UpdateEntitySource do
  subject { create(:entity_source, :external, certificate: certificate.to_pem) }
  before { stub_request(:get, subject.url).to_return(response) }
  let(:response) { { status: 200, headers: {}, body: signed_xml } }
  let(:doc) { Nokogiri::XML.parse(xml) }
  let(:signed_xml) { Xmldsig::SignedDocument.new(xml).sign(key) }

  let(:entity_ids) do
    doc.xpath('//*[local-name() = "EntityDescriptor"]/@entityID').map(&:value)
  end

  let(:key) { create(:rsa_key) }
  let(:certificate) { create(:certificate, rsa_key: key) }

  let(:federation_tag) { Faker::Lorem.word }

  def swallow
    yield
  rescue => e
    @exception = e
  end

  def run
    described_class.perform(id: subject.id, primary_tag: federation_tag)
  end

  def entity_descriptors(entities:)
    fragments = (1..entities).map do
      attributes_for(:raw_entity_descriptor)[:xml]
      .gsub('xmlns="urn:oasis:names:tc:SAML:2.0:metadata"', '')
      .strip
    end
    fragments.join("\n")
  end

  EMPTY_SIGNATURE = <<-EOF.strip_heredoc
    <ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
      <ds:SignedInfo>
        <ds:CanonicalizationMethod
          Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
        <ds:SignatureMethod
          Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256"/>

        <ds:Reference URI="#_x">
          <ds:Transforms>
            <ds:Transform Algorithm=
              "http://www.w3.org/2000/09/xmldsig#enveloped-signature" />
            <ds:Transform
              Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
          </ds:Transforms>

          <ds:DigestMethod
            Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"/>
          <ds:DigestValue></ds:DigestValue>
        </ds:Reference>
      </ds:SignedInfo>

      <ds:SignatureValue></ds:SignatureValue>
    </ds:Signature>
  EOF

  def entities_descriptor(fore: nil, entities:)
    [
      '<EntitiesDescriptor xmlns="urn:oasis:names:tc:SAML:2.0:metadata" ',
      'ID="_x">',
      EMPTY_SIGNATURE.indent(2),
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

    it 'has known_entity with federation tag' do
      run
      expect(subject.known_entities.last.tags.first.name).to eq(federation_tag)
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
        .to eq(Nokogiri::XML.parse(xml).root.elements[1].canonicalize)
    end

    context 'when the entity already exists' do
      let!(:entity) do
        create :known_entity, entity_source: subject, active: true
      end

      context 'when the raw entity descriptor already exists' do
        let!(:red) do
          create :raw_entity_descriptor, xml: old_xml,
                                         entity_id_uri: entity_id,
                                         known_entity: entity
        end
        let(:hostname) { URI.parse(entity_id).hostname }

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
          new_xml = Nokogiri::XML.parse(xml).root.elements[1].canonicalize
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

  context 'when an entity is removed' do
    let(:xml) { entities_descriptor(entities: 1) }
    let!(:entity) { create(:known_entity, entity_source: subject) }
    let!(:red) { create(:raw_entity_descriptor, known_entity: entity) }

    let(:old_xml) do
      hostname = URI.parse(entity_ids[0]).host
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

    let!(:other_entity) do
      create :known_entity, entity_source: subject, active: true
    end

    let!(:other_red) do
      create :raw_entity_descriptor, xml: old_xml,
                                     known_entity: other_entity,
                                     entity_id_uri: entity_ids[0]
    end

    it 'removes the known entity' do
      expect { run }.to change(KnownEntity, :count).by(-1)
      expect { entity.reload }.to raise_error(/Record not found/)
    end

    it 'removes the raw entity descriptor' do
      expect { run }.to change(RawEntityDescriptor, :count).by(-1)
      expect { red.reload }.to raise_error(/Record not found/)
    end

    it 'leaves the other entity intact' do
      run
      expect { other_entity.reload }.not_to raise_error
    end

    it 'leaves the other raw entity descriptor intact' do
      run
      expect { other_red.reload }.not_to raise_error
    end
  end

  context 'with invalid xml' do
    let(:xml) do
      entities_descriptor(entities: 1) .gsub(/entityID="[^"]+"/, '')
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

  context 'with an invalid signature' do
    let(:wrong_key) { OpenSSL::PKey::RSA.new(1024) }
    let(:xml) { entities_descriptor(entities: 1) }
    let(:signed_xml) { Xmldsig::SignedDocument.new(xml).sign(wrong_key) }

    it 'raises an informative message' do
      swallow { run }
      expect(@exception.message)
        .to match('Unable to update EntitySource')
        .and match(subject.url)
        .and match('Signature validation failed')
    end
  end
end
