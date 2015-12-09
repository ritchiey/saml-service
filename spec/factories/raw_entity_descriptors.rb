FactoryGirl.define do
  factory :raw_entity_descriptor do
    transient do
      hostname { "raw.#{Faker::Internet.domain_name}" }
      entity_id_uri { "https://#{hostname}/shibboleth" }
    end

    enabled true

    association :known_entity

    xml do
      <<-EOF.strip_heredoc
        <EntityDescriptor xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
          xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
          entityID="#{entity_id_uri}">
          <Extensions>
            <mdui:UIInfo>
              <mdui:DisplayName xml:lang="en">
                #{Faker::Lorem.word}
              </mdui:DisplayName>
              <mdui:Description xml:lang="en">
                #{Faker::Lorem.sentence}
              </mdui:Description>
              <mdui:Logo height="16" width="16">
                 https://example.edu/img.png
             </mdui:Logo>
             <mdui:InformationURL xml:lang="en">
                #{Faker::Internet.url}
              </mdui:InformationURL>
              <mdui:PrivacyStatementURL xml:lang="en">
                #{Faker::Internet.url}
              </mdui:PrivacyStatementURL>
            </mdui:UIInfo>
            <mdui:DiscoHints>
              <mdui:IPHint>2001:620::0/96</mdui:IPHint>
              <mdui:DomainHint>example.edu</mdui:DomainHint>
              <mdui:GeolocationHint>geo:47.37328,8.531126</mdui:GeolocationHint>
            </mdui:DiscoHints>
          </Extensions>
          <AttributeAuthorityDescriptor
              protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
            <AttributeService
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP"
                Location="https://#{hostname}/idp/profile/AttributeQuery/SOAP"/>
          </AttributeAuthorityDescriptor>
        </EntityDescriptor>
      EOF
    end

    after :create do |red, eval|
      red.entity_id = create :raw_entity_id, uri: eval.entity_id_uri,
                                             raw_entity_descriptor: red
    end

    factory :raw_entity_descriptor_idp do
      xml do
        <<-EOF.strip_heredoc
          <EntityDescriptor xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
              entityID="#{entity_id_uri}">
            <IDPSSODescriptor
              protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
              <SingleSignOnService
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP"
                Location="https://#{hostname}/idp/profile/SAML2/Redirect/SSO"/>
            </IDPSSODescriptor>
          </EntityDescriptor>
        EOF
      end
    end

    factory :raw_entity_descriptor_sp do
      xml do
        <<-EOF.strip_heredoc
          <EntityDescriptor xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
              entityID="#{entity_id_uri}">
            <SPSSODescriptor
              protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
              <AssertionConsumerService
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
                Location="https://#{hostname}/Shibboleth.sso/SAML2/POST"
                index="1" isDefault="true" />
            </SPSSODescriptor>
          </EntityDescriptor>
        EOF
      end
    end
  end
end
