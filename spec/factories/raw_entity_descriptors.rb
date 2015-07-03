FactoryGirl.define do
  factory :raw_entity_descriptor do
    enabled true

    transient { hostname { "raw.#{Faker::Internet.domain_name}" } }

    known_entity do
      create(:known_entity, entity_id: "https://#{hostname}/idp/shibboleth")
    end

    xml do
      <<-EOF.strip_heredoc
        <EntityDescriptor xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
            entityID="#{known_entity.entity_id}">
          <AttributeAuthorityDescriptor
              protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
            <AttributeService
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP"
                Location="https://#{hostname}/idp/profile/AttributeQuery/SOAP"/>
          </AttributeAuthorityDescriptor>
        </EntityDescriptor>
      EOF
    end

    after :create do |red|
      red.entity_id = create :raw_entity_id, raw_entity_descriptor: red
    end
  end
end
