require 'rails_helper'

require 'metadata/saml'

RSpec.describe Metadata::SAML do
  subject do
    Metadata::SAML.new(federation_identifier: federation_identifier,
                       metadata_name: metadata_name,
                       metadata_validity_period: metadata_validity_period)
  end

  let(:federation_identifier) { Faker::Internet.domain_word }
  let(:metadata_name) { "urn:mace:#{federation_identifier}.edu:test" }
  let(:metadata_validity_period) { 1.weeks }

  let(:builder) { subject.builder }
  let(:raw_xml) { builder.to_xml }
  let(:xml) do
    # Pull out xmlns so our tests don't need to specify it everywhere
    # as we expect metadata nodes to live under this namespace by default
    raw_xml.sub!('xmlns="urn:oasis:names:tc:SAML:2.0:metadata"', '')
    Capybara::Node::Simple.new(Nokogiri::XML.parse(raw_xml))
  end

  include_examples 'SAML namespaces'

  it 'renders xml' do
    expect(subject.to_xml).to eq(raw_xml)
  end

  context 'EntitiesDescriptors' do
    let(:entities_descriptor) { create :basic_federation }
    let(:add_ca_keys) { false }
    let(:add_publisher_info) { false }
    let(:add_child_entities_descriptors) { false }
    let(:namespaces) { Nokogiri::XML.parse(raw_xml).collect_namespaces }

    let(:entities_descriptor_path) { '/EntitiesDescriptor' }
    let(:extensions_path) { '/EntitiesDescriptor/Extensions' }
    let(:key_authority_path) { "#{extensions_path}/shibmd:KeyAuthority" }
    let(:key_info_path) { "#{key_authority_path}/ds:KeyInfo" }
    let(:publication_info_path) { "#{extensions_path}/mdrpi:PublicationInfo" }
    let(:usage_policy_path) { "#{publication_info_path}/mdrpi:UsagePolicy" }
    let(:entity_descriptor_path) do
      "#{entities_descriptor_path}/EntityDescriptor"
    end
    let(:child_entities_descriptors_path) do
      '/EntitiesDescriptor/EntitiesDescriptor'
    end

    before :each do
      if add_ca_keys
        create_list(:ca_key_info, 2, entities_descriptor: entities_descriptor)
      end

      if add_publisher_info
        entities_descriptor.publication_info =
        create(:mdrpi_publication_info,
               entities_descriptor: entities_descriptor)

        entities_descriptor.publication_info
          .add_usage_policy(create :mdrpi_usage_policy,
                                   publication_info:
                                     entities_descriptor.publication_info)
      end

      if add_child_entities_descriptors
        create_list(:entities_descriptor, 2,
                    parent_entities_descriptor: entities_descriptor)
      end
    end

    RSpec.shared_examples 'entities descriptor xml' do
      it 'is created' do
        expect(xml).to have_xpath(entities_descriptor_path)
      end

      context 'CA keys' do
        context 'without CA keys' do
          it 'does not populate Extensions node' do
            expect(xml).not_to have_xpath(extensions_path)
          end
        end

        context 'with CA keys' do
          let(:add_ca_keys) { true }
          context 'Extensions' do
            it 'is created' do
              expect(xml).to have_xpath(extensions_path)
            end
            context 'KeyAuthority' do
              it 'is created' do
                expect(xml).to have_xpath(key_authority_path)
              end
              context 'attributes' do
                let(:node) { xml.find(:xpath, key_authority_path) }
                it 'sets VerifyDepth' do
                  expect(node['VerifyDepth'])
                    .to eq(entities_descriptor.ca_verify_depth.to_s)
                end
              end
              context 'KeyInfo' do
                it 'creates two instances' do
                  expect(xml).to have_xpath(key_info_path, count: 2)
                end
              end
            end
          end
        end
      end

      context 'MDRPI Publisher Info' do
        let(:add_publisher_info) { true }
        context 'Extensions' do
          it 'is created' do
            expect(xml).to have_xpath(extensions_path)
          end
          context 'PublisherInfo' do
            it 'is created' do
              expect(xml).to have_xpath(publication_info_path)
            end
            context 'attributes' do
              let(:node) { xml.find(:xpath, publication_info_path) }
              it 'sets publisher' do
                expect(node['publisher'])
                  .to eq(entities_descriptor.publication_info.publisher)
              end
              it 'sets creationInstant' do
                expect(node['creationInstant'])
                  .to eq(subject.created_at.xmlschema)
              end
              it 'sets publicationId' do
                expect(node['publicationId']).to eq(subject.instance_id)
                  .and start_with(federation_identifier)
              end
            end
            context 'UsagePolicy' do
              it 'is created' do
                expect(xml).to have_xpath(usage_policy_path, count: 2)
              end
              context 'attributes' do
                let(:node) { xml.first(:xpath, usage_policy_path) }
                it 'sets lang' do
                  expect(node['lang'])
                    .to eq(entities_descriptor.publication_info
                           .usage_policies.first.lang)
                end
              end
              context 'value' do
                let(:node) { xml.first(:xpath, usage_policy_path) }
                it 'stores expected URL' do
                  expect(node.text).to eq(entities_descriptor.publication_info
                                          .usage_policies.first.uri)
                end
              end
            end
          end
        end
      end

      context 'child EntitiesDescriptors' do
        context 'not defined' do
          it 'does not have child EntitiesDescriptors' do
            expect(xml).not_to have_xpath(child_entities_descriptors_path)
          end
        end

        context 'defined' do
          let(:add_child_entities_descriptors) { true }
          it 'does have child EntitiesDescriptors' do
            expect(xml)
              .to have_xpath(child_entities_descriptors_path, count: 2)
          end
        end
      end

      context 'EntityDescriptors' do
        it 'is created' do
          expect(xml).to have_xpath(entity_descriptor_path, count: 5)
        end
      end
    end

    context 'Root EntitiesDescriptor' do
      before { subject.root_entities_descriptor(entities_descriptor) }
      include_examples 'entities descriptor xml'

      it 'defines namespaces' do
        expect(namespaces).to eq(Metadata::SAML::NAMESPACES)
      end

      context 'attributes' do
        let(:node) { xml.find(:xpath, entities_descriptor_path) }

        around { |example| Timecop.freeze { example.run } }

        it 'sets ID' do
          expect(node['ID']).to eq(subject.instance_id)
            .and start_with(federation_identifier)
        end
        it 'sets Name' do
          expect(node['Name']).to eq(metadata_name)
        end
        it 'sets validUntil' do
          expect(node['validUntil'])
            .to eq((Time.now.utc + metadata_validity_period).xmlschema)
        end
      end
    end

    context 'Child EntitiesDescriptors' do
      before { subject.entities_descriptor(entities_descriptor) }
      include_examples 'entities descriptor xml'

      context 'attributes' do
        let(:node) { xml.find(:xpath, entities_descriptor_path) }

        around { |example| Timecop.freeze { example.run } }

        it 'does not set ID' do
          expect(node['ID']).not_to be
        end
        it 'does not set Name' do
          expect(node['Name']).not_to be
        end
        it 'does not set validUntil' do
          expect(node['validUntil']).not_to be
        end
      end
    end
  end

  context 'KeyInfo' do
    let(:key_info) { create :key_info }
    let(:key_info_path) { '/ds:KeyInfo' }
    let(:key_name_path) { "#{key_info_path}/ds:KeyName" }
    let(:x509_data_path) { "#{key_info_path}/ds:X509Data" }
    let(:x509_subject_name_path) { "#{x509_data_path}/ds:X509SubjectName" }
    let(:x509_certificate_path) { "#{x509_data_path}/ds:X509Certificate" }

    before { subject.key_info(key_info) }

    it 'is created' do
      expect(xml).to have_xpath(key_info_path)
    end

    context 'KeyName' do
      context 'is set' do
        let(:node) { xml.find(:xpath, key_name_path) }
        it 'is created' do
          expect(xml).to have_xpath(key_name_path)
        end
        it 'has correct value' do
          expect(node.text).to eq(key_info.key_name)
        end
      end
      context 'is not set' do
        let(:key_info) { create :key_info, key_name: nil }
        it 'is not created' do
          expect(xml).not_to have_xpath(key_name_path)
        end
      end
    end

    context 'X509Data' do
      it 'is created' do
        expect(xml).to have_xpath(x509_data_path)
      end
      context 'X509SubjectName' do
        let(:node) { xml.find(:xpath, x509_subject_name_path) }
        it 'is created' do
          expect(xml).to have_xpath(x509_subject_name_path)
        end
        it 'has correct value' do
          expect(node.text).to eq(key_info.subject)
        end
      end
      context 'X509Certificate' do
        let(:node) { xml.find(:xpath, x509_certificate_path) }
        it 'is created' do
          expect(xml).to have_xpath(x509_certificate_path)
        end
        it 'has correct value' do
          expect(node.text).to eq(key_info.certificate_without_anchors)
        end
      end
    end
  end

  context 'EntityDescriptors', focus: true do
    let(:entity_descriptor) { create :entity_descriptor }
    let(:entity_descriptor_path) { '/EntityDescriptor' }

    RSpec.shared_examples 'entity descriptor xml' do
      it 'is created' do
        expect(xml).to have_xpath(entity_descriptor_path)
      end

      context 'attributes' do
        let(:node) { xml.find(:xpath, entity_descriptor_path) }
        it 'has correct entityID' do
          expect(node['entityID']).to eq(entity_descriptor.entity_id.uri)
        end
      end
    end

    context 'Root EntityDescriptor' do
      before { subject.root_entity_descriptor(entity_descriptor) }
      include_examples 'entity descriptor xml'

      context 'attributes' do
        let(:node) { xml.find(:xpath, entity_descriptor_path) }

        it 'sets ID' do
          expect(node['ID']).to eq(subject.instance_id)
            .and start_with(federation_identifier)
        end
        it 'sets validUntil' do
          expect(node['validUntil'])
            .to eq((Time.now.utc + metadata_validity_period).xmlschema)
        end
      end
    end

    context 'Child EntityDescriptor' do
      before { subject.entity_descriptor(entity_descriptor) }
      include_examples 'entity descriptor xml'

      context 'attributes' do
        let(:node) { xml.find(:xpath, entity_descriptor_path) }

        it 'sets ID' do
          expect(node['ID']).not_to be
        end
        it 'sets validUntil' do
          expect(node['validUntil']).not_to be
        end
      end
    end
  end
end
