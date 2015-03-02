RSpec.shared_examples 'RawEntityDescriptor xml' do
  let(:ed_xml) do
    <<-EOF.strip_heredoc
      <EntityDescriptor xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
          entityID="https://test.example.com/idp/shibboleth">
        <AttributeAuthorityDescriptor
            protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
          <AttributeService
              Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP"
              Location="https://example.com/idp/profile/AttributeQuery/SOAP"/>
        </AttributeAuthorityDescriptor>
      </EntityDescriptor>
    EOF
  end

  let(:raw_entity_descriptor) { create(:raw_entity_descriptor, xml: ed_xml) }
  let(:known_entity) { raw_entity_descriptor.known_entity }
  let(:entity_source) { known_entity.entity_source }

  before { subject.entities_descriptor([known_entity]) }

  it 'is included in the output' do
    xpath = '//EntityDescriptor' \
            '[@entityID="https://test.example.com/idp/shibboleth"]'
    expect(xml).to have_xpath(xpath)
  end
end
