FactoryGirl.define do
  factory :raw_entity_descriptor do
    transient { hostname "raw.#{Faker::Internet.domain_name}" }

    association :known_entity
    xml do
      <<-EOF.strip_heredoc
        <EntityDescriptor xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
            entityID="https://#{hostname}/idp/shibboleth">
          <AttributeAuthorityDescriptor
              protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
            <AttributeService
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP"
                Location="https://#{hostname}/idp/profile/AttributeQuery/SOAP"/>
          </AttributeAuthorityDescriptor>
        </EntityDescriptor>
      EOF
    end
  end
end
