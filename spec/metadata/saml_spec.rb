require 'rails_helper'

require 'metadata/saml'

RSpec.describe Metadata::SAML do
  subject do
    Metadata::SAML.new(metadata_instance: metadata_instance,
                       federation_identifier: federation_identifier,
                       metadata_name: metadata_name,
                       metadata_validity_period: metadata_validity_period)
  end

  let(:federation_identifier) { Faker::Internet.domain_word }
  let(:metadata_name) { "urn:mace:#{federation_identifier}.edu:test" }
  let(:metadata_validity_period) { 1.weeks }
  let(:metadata_instance) { create(:metadata_instance) }
  let(:entity_descriptors) { entity_source.entity_descriptors }

  let(:builder) { subject.builder }
  let(:raw_xml) { builder.to_xml }
  let(:xml) do
    # Pull out xmlns so our tests don't need to specify it everywhere
    # as we expect metadata nodes to live under this namespace by default
    raw_xml.sub!('xmlns="urn:oasis:names:tc:SAML:2.0:metadata"', '')
    Capybara::Node::Simple.new(Nokogiri::XML.parse(raw_xml))
  end

  # Nodes which by schema may validly appear in multiple locations
  let(:all_publication_infos) { '//mdrpi:PublicationInfo' }

  context 'SAML namespaces' do
    include_examples 'SAML namespaces'
  end

  context 'EntitiesDescriptors' do
    let(:entity_source) { create :basic_federation }
    include_examples 'EntitiesDescriptor xml'
  end

  context 'KeyInfo' do
    let(:key_info) { create :key_info }
    before { subject.key_info(key_info) }
    include_examples 'ds:KeyInfo xml'
  end

  context 'PublisherInfo' do
    let(:entity_source) { create(:basic_federation) }
    let(:entity_descriptor) do
      create(:entity_descriptor, :with_publication_info)
    end
    context 'EntitiesDescriptor' do
      before { subject.publication_info(metadata_instance) }
      include_examples 'mdrpi:PublisherInfo xml' do
        let(:root_node) { metadata_instance }
      end
    end
    context 'EntityDescriptor' do
      before { subject.publication_info(entity_descriptor) }
      include_examples 'mdrpi:PublisherInfo xml' do
        let(:root_node) { entity_descriptor }
      end
    end
  end

  context 'EntityDescriptors' do
    include_examples 'EntityDescriptor xml'
  end

  context 'RegistrationInfo' do
    let(:metadata_instance) do
      create(:metadata_instance, :with_registration_info)
    end
    let(:entity_descriptor) { create(:entity_descriptor) }
    context 'EntitiesDescriptor' do
      before { subject.registration_info(metadata_instance) }
      include_examples 'mdrpi:RegistrationInfo xml' do
        let(:root_node) { metadata_instance }
      end
    end
    context 'EntityDescriptor' do
      before { subject.registration_info(entity_descriptor) }
      include_examples 'mdrpi:RegistrationInfo xml' do
        let(:root_node) { entity_descriptor }
      end
    end
  end

  context 'Organizations' do
    let(:organization) do
      create :organization, :with_multiple_organization_languages
    end
    before { subject.organization(organization) }
    include_examples 'Organization xml'
  end

  context 'ContactPersons' do
    let(:contact_person) { create :contact_person }
    before { subject.contact_person(contact_person) }
    include_examples 'ContactPerson xml'
  end

  context 'EntityAttributes' do
    let(:entity_attribute) { create :mdattr_entity_attribute }
    before { subject.entity_attribute(entity_attribute) }
    include_examples 'mdattr:EntityAttribute xml'
  end

  context 'Attributes and AttributeValues' do
    let(:attribute) { create :attribute }
    before { subject.attribute(attribute) }
    include_examples 'saml:Attribute xml'
  end

  context 'RoleDescriptors' do
    include_examples 'RoleDescriptor xml' do
      let(:role_descriptor_path) { '/RoleDescriptor' }
      let(:parent_node) { :role_descriptor }
      let(:role_descriptor) { create parent_node }
      before do
        subject.root.RoleDescriptor(subject.ns) do |rd|
          subject.role_descriptor(role_descriptor, rd)
        end
      end
    end
  end

  context 'KeyDescriptors' do
    let(:key_descriptor) { create :key_descriptor }
    before { subject.key_descriptor(key_descriptor) }
    include_examples 'KeyDescriptor xml'
  end

  context 'SSODescriptors' do
    include_examples 'SSODescriptor xml' do
      # In reality this XML path is not valid, but utilising it
      # here makes for finer grained tests
      let(:sso_descriptor_path) { '/SSODescriptor' }
      let(:parent_node) { :sso_descriptor }
      let(:sso_descriptor) { create parent_node }
      before do
        subject.root.SSODescriptor(subject.ns) do |ssod|
          subject.sso_descriptor(sso_descriptor, ssod)
        end
      end
    end
  end

  context 'Endpoint' do
    include_examples 'Endpoint xml' do
      let(:endpoint_path) { '/Endpoint' }
      let(:parent_node) { :_endpoint }
      let(:endpoint) { create parent_node }
      before do
        subject.root.Endpoint(subject.ns) do |ep|
          subject.endpoint(endpoint, ep)
        end
      end
    end
  end

  context 'IndexedEndpoint' do
    include_examples 'IndexedEndpoint xml' do
      let(:endpoint_path) { '/IndexedEndpoint' }
      let(:parent_node) { :_indexed_endpoint }
      let(:endpoint) { create parent_node }
      before do
        subject.root.IndexedEndpoint(subject.ns) do |ep|
          subject.indexed_endpoint(endpoint, ep)
        end
      end
    end
  end

  context 'ArtifactResolutionService' do
    include_examples 'IndexedEndpoint xml' do
      let(:endpoint_path) { '/ArtifactResolutionService' }
      let(:parent_node) { :artifact_resolution_service }
      let(:endpoint) { create parent_node }
      before { subject.artifact_resolution_service(endpoint) }
    end
  end

  context 'SingleLogoutService' do
    include_examples 'Endpoint xml' do
      let(:endpoint_path) { '/SingleLogoutService' }
      let(:parent_node) { :single_logout_service }
      let(:endpoint) { create parent_node }
      before { subject.single_logout_service(endpoint) }
    end
  end

  context 'ManageNameIDService' do
    include_examples 'Endpoint xml' do
      let(:endpoint_path) { '/ManageNameIDService' }
      let(:parent_node) { :manage_name_id_service }
      let(:endpoint) { create parent_node }
      before { subject.manage_name_id_service(endpoint) }
    end
  end

  context 'IDPSSODescriptor' do
    let(:idp_sso_descriptor_path) { '/IDPSSODescriptor' }

    context 'Parent nodes and abstract types' do
      let(:parent_node) { :idp_sso_descriptor }

      context 'RoleDescriptorType' do
        let(:role_descriptor_path) { idp_sso_descriptor_path }
        let(:role_descriptor) { create parent_node }
        before { subject.idp_sso_descriptor(role_descriptor) }
        include_examples 'RoleDescriptor xml'
      end

      context 'SSODescriptorType' do
        let(:sso_descriptor_path) { idp_sso_descriptor_path }
        let(:sso_descriptor) { create parent_node }
        before { subject.idp_sso_descriptor(sso_descriptor) }
        include_examples 'SSODescriptor xml'
      end
    end

    context 'IDPSSODescriptorType' do
      let(:idp_sso_descriptor) { create :idp_sso_descriptor }
      before { subject.idp_sso_descriptor(idp_sso_descriptor) }
      include_examples 'IDPSSODescriptor xml'
    end
  end

  context 'SingleSignOnService' do
    include_examples 'Endpoint xml' do
      let(:endpoint_path) { '/SingleSignOnService' }
      let(:parent_node) { :single_sign_on_service }
      let(:endpoint) { create parent_node }
      before { subject.single_sign_on_service(endpoint) }
    end
  end

  context 'NameIDMappingService' do
    include_examples 'Endpoint xml' do
      let(:endpoint_path) { '/NameIDMappingService' }
      let(:parent_node) { :name_id_mapping_service }
      let(:endpoint) { create parent_node }
      before { subject.name_id_mapping_service(endpoint) }
    end
  end

  context 'AssertionIDRequestService' do
    include_examples 'Endpoint xml' do
      let(:endpoint_path) { '/AssertionIDRequestService' }
      let(:parent_node) { :assertion_id_request_service }
      let(:endpoint) { create parent_node }
      before { subject.assertion_id_request_service(endpoint) }
    end
  end

  context 'SPSSODescriptor' do
    let(:sp_sso_descriptor_path) { '/SPSSODescriptor' }

    context 'Parent nodes and abstract types' do
      let(:parent_node) { :sp_sso_descriptor }

      context 'RoleDescriptorType' do
        let(:role_descriptor_path) { sp_sso_descriptor_path }
        let(:role_descriptor) { create parent_node }
        before { subject.sp_sso_descriptor(role_descriptor) }
        include_examples 'RoleDescriptor xml'
      end

      context 'SSODescriptorType' do
        let(:sso_descriptor_path) { sp_sso_descriptor_path }
        let(:sso_descriptor) { create parent_node }
        before { subject.sp_sso_descriptor(sso_descriptor) }
        include_examples 'SSODescriptor xml'
      end
    end

    context 'SPSSODescriptorType' do
      let(:sp_sso_descriptor) { create :sp_sso_descriptor }
      before { subject.sp_sso_descriptor(sp_sso_descriptor) }
      include_examples 'SPSSODescriptor xml'
    end
  end

  context 'AssertionConsumerService' do
    include_examples 'IndexedEndpoint xml' do
      let(:endpoint_path) { '/AssertionConsumerService' }
      let(:parent_node) { :assertion_consumer_service }
      let(:endpoint) { create parent_node }
      before { subject.assertion_consumer_service(endpoint) }
    end
  end

  context 'AttributeConsumingService' do
    let(:attribute_consuming_service_path) { '/AttributeConsumingService' }
    let(:attribute_consuming_service) { create :attribute_consuming_service }
    before { subject.attribute_consuming_service(attribute_consuming_service) }
    include_examples 'AttributeConsumingService xml'
  end

  context 'RequestedAttributes' do
    let(:requested_attribute_path) { '/RequestedAttribute' }
    let(:requested_attribute) { create :requested_attribute }
    before { subject.requested_attribute(requested_attribute) }
    include_examples 'RequestedAttribute xml'
  end

  context 'AttributeAuthorityDescriptor' do
    let(:attribute_authority_descriptor_path) do
      '/AttributeAuthorityDescriptor'
    end

    context 'RoleDescriptorType' do
      let(:parent_node) { :attribute_authority_descriptor }
      let(:role_descriptor_path) { attribute_authority_descriptor_path }
      let(:role_descriptor) { create parent_node }
      before { subject.attribute_authority_descriptor(role_descriptor) }
      include_examples 'RoleDescriptor xml'
    end

    context 'AttributeAuthorityDescriptorType' do
      let(:attribute_authority_descriptor) do
        create :attribute_authority_descriptor
      end
      before do
        subject.attribute_authority_descriptor(attribute_authority_descriptor)
      end
      include_examples 'AttributeAuthorityDescriptor xml'
    end
  end

  context 'AttributeService' do
    include_examples 'Endpoint xml' do
      let(:endpoint_path) { '/AttributeService' }
      let(:parent_node) { :attribute_service }
      let(:endpoint) { create parent_node }
      before { subject.attribute_service(endpoint) }
    end
  end
end
